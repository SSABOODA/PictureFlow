//
//  HomeViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/13/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

class PostListViewController: UIViewController {
    
    let mainView = PostListView()
    let viewModel = PostListViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, PostListViewController.description())
        navigationItem.title = "FLOW"
        bind()
        configureRefreshControl()
        setNavigationBarBackButtonItem(title: "뒤로", color: UIColor(resource: .tint))
        
        printAccessToken() // @Deprecated
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function, PostListViewController.description())
        self.viewModel.updateDateSource()
    }
    
    func printAccessToken() {
//        let accessToken = KeyChain.read(key: "accessToken")!
//        let refreshToken = KeyChain.read(key: "refreshToken")!
//        print("accessToken: \(accessToken)")
//        print("refreshToken: \(refreshToken)")
    }
    
    func configureRefreshControl() {
        mainView.refreshControl.endRefreshing()
        mainView.tableView.refreshControl = mainView.refreshControl
        
        mainView.refreshControl.rx.controlEvent(.valueChanged)
            .asObservable()
            .bind(with: self) { owner, _ in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    owner.viewModel.updateDateSource()
                    owner.mainView.refreshControl.endRefreshing()
                }
                owner.viewModel.refreshLoading.accept(true)
            }
            .disposed(by: disposeBag)
    }

    private func bind() {
        let input = PostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.refreshLoading
            .bind(to: mainView.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                print("postListVC error: \(error.message) \(error.statusCode)")
            }
            .disposed(by: disposeBag)
        
        output.postListItem
            .bind(to: mainView.tableView.rx.items(
                cellIdentifier: PostListTableViewCell.description(),
                cellType: PostListTableViewCell.self)) { (row, element, cell) in
                    
                    // cell 데이터 구성
                    cell.configureCell(with: element)
                    
                    // 좋아요 버튼
                    var likeCount = element.likes.count
                    
                    cell.likeButton.rx.tap
                        .throttle(.seconds(1), scheduler: MainScheduler.instance)
                        .flatMap {
                            Network.shared.requestObservableConvertible(
                                type: LikeRetrieveResponse.self,
                                router: .like(
                                    accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                                    postId: self.viewModel.postListDataSource[row]._id
                                )
                            )
                        }
                        .observe(on: MainScheduler.instance)
                        .bind(with: self) { owner, result in
                            switch result {
                            case .success(let data):
                                print("like network data: \(data)")

                                if data.likeStatus {
                                    owner.viewModel.postListDataSource[row].likes.append(UserDefaultsManager.userID)
                                    cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                    cell.likeButton.tintColor = .red
                                    likeCount += 1
                                } else {
                                    if let index = owner.viewModel.postListDataSource[row].likes.firstIndex(of: UserDefaultsManager.userID) {
                                        owner.viewModel.postListDataSource[row].likes.remove(at: index)
                                    }
                                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                    cell.likeButton.tintColor = UIColor(resource: .tint)
                                    if likeCount >= 1 { likeCount -= 1 }
                                }
                                owner.viewModel.postListItem.onNext(owner.viewModel.postListDataSource)
                                cell.likeCountButton.setTitle("\(likeCount) 좋아요", for: .normal)
                            case .failure(let error):
                                print(error)
                            }
                        }
                        .disposed(by: cell.disposeBag)
                    
                    // 댓글 버튼
                    cell.commentButton.rx.tap
                        .bind(with: self) { owner, _ in
                            print("comment button tap")
                            let vc = CommentCreateViewController()
                            vc.completionHandler = { _ in
                                let newCommetCount = element.comments.count + 1
                                cell.commentCountButton.setTitle("\(newCommetCount) 답글", for: .normal)
                            }
                            let _id = owner.viewModel.postListDataSource[row]._id
                            vc.viewModel.postId = _id
                            owner.transition(viewController: vc, style: .presentNavigation)
                        }
                        .disposed(by: cell.disposeBag)
                    
                    // 더보기 버튼
                    cell.moreInfoButton.rx.tap
                        .observe(on: MainScheduler.instance)
                        .bind(with: self) { owner, _ in
                            print("post list view more button did tap")
                            if element.creator._id == UserDefaultsManager.userID {
                                let bottomSheetVC = PostListBottomSheetViewController()
                                bottomSheetVC.completion = { isDeleted in
                                    if isDeleted {
                                        owner.viewModel.updateDateSource()
                                    }
                                }
                                bottomSheetVC.post = owner.viewModel.postListDataSource[row]
                                bottomSheetVC.postId = owner.viewModel.postListDataSource[row]._id
                                bottomSheetVC.modalPresentationStyle = .overFullScreen
                                self.present(bottomSheetVC, animated: false)
                            } else {
                                let bottomSheetVC = OtherUserPostBottomSheetViewController()
                                bottomSheetVC.modalPresentationStyle = .overFullScreen
                                self.present(bottomSheetVC, animated: false)
                            }
                        }
                        .disposed(by: cell.disposeBag)

                }
                .disposed(by: disposeBag)
        
        Observable.zip(
            mainView.tableView.rx.itemSelected,
            mainView.tableView.rx.modelSelected(PostList.self)
        )
            .map {
                let item = $0.1
                return PostList(
                    _id: item._id,
                    likes: item.likes,
                    image: item.image,
                    title: item.title,
                    content: item.content,
                    time: item.time,
                    productID: item.productID,
                    creator: item.creator,
                    comments: item.comments
                )
            }
            .subscribe(with: self) { owner, value in
                print("cell clicked")
                let vc = PostDetailViewController()
                vc.viewModel.postList = value
                owner.transition(viewController: vc, style: .push)
            }
            .disposed(by: disposeBag)
        
        // pagination
        mainView.tableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .withUnretained(self)
            .bind(with: self) { owner, rowSet in
                let row = rowSet.1
                guard row == owner.viewModel.postListDataSource.count - 1 else { return }
                
                let nextCursor = owner.viewModel.nextCursor
                if nextCursor != "0" {
                    owner.viewModel.prefetchData(next: nextCursor)
                }
            }
            .disposed(by: disposeBag)
        
        // pull to refresh
        output.refreshLoading
            .bind(to: mainView.refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        
    }
}

