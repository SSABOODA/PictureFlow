//
//  ProfileChileMyPostListViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileChildMyPostListViewController: UIViewController {
    
    let mainView = ProfileChileMyPostListView()
    let viewModel = ProfileChildMyPostListViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingRefreshControl()
        bind()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateDataSource(_:)),
            name: NSNotification.Name("updateDataSource"),
            object: nil
        )
        
        tabBarController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func updateDataSource(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let isUpdate = userInfo["isUpdate"] as? Bool else { return }
        if isUpdate {
            self.viewModel.fetchProfileMyPostListData()
        }
    }
    
    private func emptyViewBind() {
        mainView.firstStartButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = NewPostWriteViewController()
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindingRefreshControl() {
        mainView.refreshControl.endRefreshing()
        mainView.tableView.refreshControl = mainView.refreshControl
        
        mainView.refreshControl.rx.controlEvent(.valueChanged)
            .asObservable()
            .bind(with: self) { owner, _ in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    owner.viewModel.fetchProfileMyPostListData()
                    owner.mainView.refreshControl.endRefreshing()
                }
                owner.viewModel.refreshLoading.accept(true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        emptyViewBind()
        let input = ProfileChildMyPostListViewModel.Input()
        let output = viewModel.transform(input: input)
        
        // pagination
        mainView.tableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .withUnretained(self)
            .bind(with: self) { owner, rowSet in
                let row = rowSet.1
                guard row <= owner.viewModel.postList.count - 2 else { return }
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

        // activityIndicator
        output.activityLoaing
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, visible in
                let activityIndicator = owner.mainView.activityIndicator
                owner.setVisibleWithAnimation(activityIndicator, visible)
                if visible {
                    activityIndicator.startAnimating()
                } else {
                    activityIndicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
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
                                owner.showAlertAction1(message: error.message)
                            }
                        }
                        .disposed(by: cell.disposeBag)
                    
                    // 댓글 버튼
                    cell.commentButton.rx.tap
                        .bind(with: self) { owner, _ in
                            let vc = CommentCreateViewController()
                            vc.completionHandler = { newComment in
                                let newCommetCount = element.comments.count + 1
                                cell.commentCountButton.setTitle("\(newCommetCount) 답글", for: .normal)
                                owner.viewModel.postList[row].comments.insert(newComment, at: 0)
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
                            
                            let bottomSheetVC = PostListBottomSheetViewController()
                            bottomSheetVC.completion = { isDeleted in
                                if isDeleted {
                                    owner.viewModel.fetchProfileMyPostListData()
                                }
                            }
                            
                            bottomSheetVC.postUpdateCompletion = { postUpdateData in
                                owner.viewModel.postList[row] = postUpdateData
                                owner.viewModel.myPostListObservable.onNext(owner.viewModel.postList)
                            }
                            
                            bottomSheetVC.post = owner.viewModel.postList[row]
                            bottomSheetVC.postId = owner.viewModel.postList[row]._id
                            bottomSheetVC.modalPresentationStyle = .overFullScreen
                            self.present(bottomSheetVC, animated: false)
                        }
                        .disposed(by: cell.disposeBag)
                    cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        viewModel.fetchProfileMyPostListData()
        
        Observable.zip(
            mainView.tableView.rx.itemSelected,
            mainView.tableView.rx.modelSelected(PostList.self)
        )
        .subscribe(with: self) { owner, modelSelectSet in
            let indexPath = modelSelectSet.0
            let item = modelSelectSet.1
            
            var model = PostList(
                _id: item._id,
                likes: item.likes,
                image: item.image,
                title: item.title,
                content: item.content,
                time: item.time,
                productID: item.productID,
                creator: item.creator,
                comments: item.comments,
                hashTags: item.hashTags
            )
            
            model.comments = owner.viewModel.postList[indexPath.row].comments
            let vc = PostDetailViewController()
            vc.commentCreateCompletion = { [weak self] (id, newComment) in
                guard let self = self else { return }
                for (index, item) in self.viewModel.postList.enumerated() {
                    if item._id == id {
                        self.viewModel.postList[index].comments.insert(newComment, at: 0)
                        self.viewModel.myPostListObservable.onNext(self.viewModel.postList)
                    }
                }
            }
            vc.viewModel.postList = model
            owner.transition(viewController: vc, style: .push)
        }
        .disposed(by: disposeBag)
    }
}

extension ProfileChildMyPostListViewController: CustomTableViewCellDelegate {
    func didTapHashTag(in cell: PostListTableViewCell, hashTagWord: String) {
        let vc = SearchViewController()
        vc.hashTagWord = hashTagWord
        self.transition(viewController: vc, style: .push)
    }
    
    func didTapButton(in cell: PostListTableViewCell, image: UIImage) {
        let vc = FullScreenImageViewController(image: image)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension ProfileChildMyPostListViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.mainView.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return self.postViewControllerModalPresent(viewController: viewController)
    }
}
