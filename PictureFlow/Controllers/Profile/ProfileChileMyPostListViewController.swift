//
//  ProfileChileMyPostListViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileChileMyPostListViewController: UIViewController {
    
    let emptyView = ProfileChileMyPostListEmptyView()
    let mainView = ProfileChileMyPostListView()
    let viewModel = ProfileChileMyPostListViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("profile chile vc viewDidLoad")
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        viewModel.fetchProfileMyPostListData()
    }
    
    private func emptyViewBind() {
        mainView.firstStartButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = NewPostWriteViewController()
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        emptyViewBind()
        let input = ProfileChileMyPostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.myPostListObservable
            .subscribe(with: self) { owner, myPostList in
                owner.mainView.firstStartButton.isHidden = myPostList.isEmpty ? false : true
            }
            .disposed(by: disposeBag)
  
        output.myPostListObservable
            .bind(to: mainView.tableView.rx.items(
                cellIdentifier: PostListTableViewCell.description(),
                cellType: PostListTableViewCell.self)) { (row, element, cell) in
                    cell.configureCell(with: element)
                    
                    cell.profileFlollowCheckButtonView.isHidden = element.creator._id == UserDefaultsManager.userID ? true : false
                    
                    var likeCount = element.likes.count
                    cell.likeButton.rx.tap
                        .throttle(.seconds(1), scheduler: MainScheduler.instance)
                        .flatMap {
                            Network.shared.requestObservableConvertible(
                                type: LikeRetrieveResponse.self,
                                router: .like(
                                    accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                                    postId: self.viewModel.postList[row]._id
                                )
                            )
                        }
                        .observe(on: MainScheduler.instance)
                        .bind(with: self) { owner, result in
                            switch result {
                            case .success(let data):
                                print("like network data: \(data)")

                                if data.likeStatus {
                                    owner.viewModel.postList[row].likes.append(UserDefaultsManager.userID)
                                    cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                    cell.likeButton.tintColor = .red
                                    likeCount += 1
                                } else {
                                    if let index = owner.viewModel.postList[row].likes.firstIndex(of: UserDefaultsManager.userID) {
                                        owner.viewModel.postList[row].likes.remove(at: index)
                                    }
                                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                    cell.likeButton.tintColor = UIColor(resource: .tint)
                                    if likeCount >= 1 { likeCount -= 1 }
                                }
                                owner.viewModel.myPostListObservable.onNext(owner.viewModel.postList)
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
                            let _id = owner.viewModel.postList[row]._id
                            vc.viewModel.postId = _id
                            owner.transition(viewController: vc, style: .presentNavigation)
                        }
                        .disposed(by: cell.disposeBag)
                    
                    // 더보기 버튼
                    cell.moreInfoButton.rx.tap
                        .observe(on: MainScheduler.instance)
                        .bind(with: self) { owner, _ in
                            print("post list view more button did tap")
                            let bottomSheetVC = PostListBottomSheetViewController()
                            bottomSheetVC.completion = { isDeleted in
                                if isDeleted {
                                    owner.viewModel.fetchProfileMyPostListData()
                                }
                            }
                            bottomSheetVC.post = owner.viewModel.postList[row]
                            bottomSheetVC.postId = owner.viewModel.postList[row]._id
                            bottomSheetVC.modalPresentationStyle = .overFullScreen
                            self.present(bottomSheetVC, animated: false)
                        }
                        .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        viewModel.fetchProfileMyPostListData()
        
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
    }
}
