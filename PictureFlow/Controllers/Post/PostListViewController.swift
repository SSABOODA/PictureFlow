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
        configureNavigationBar()
        bindingRefreshControl()
        bind()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateDataSource(_:)),
            name: NSNotification.Name("updateDataSource"),
            object: nil
        )

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        self.removeNotificationCenterObserver(notificationName: "updateDataSource")
        self.removeNotificationCenterObserver(notificationName: "createComment")
    }
    
    @objc func updateDataSource(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let isUpdate = userInfo["isUpdate"] as? Bool else { return }
        if isUpdate {
            self.viewModel.updateDateSource()
        }
    }
    
    private func bindingRefreshControl() {
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
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
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
        
        output.postListItem
            .bind(to: mainView.tableView.rx.items(
                cellIdentifier: PostListTableViewCell.description(),
                cellType: PostListTableViewCell.self)) { (row, element, cell) in
                    
                    // cell 데이터 구성
                    cell.configureCell(with: element)
                    
                    // 팔로우 버튼
                    cell.profileFlollowCheckButtonView.isHidden = element.creator._id == UserDefaultsManager.userID ? true : false

                    let tapGesture = UITapGestureRecognizer()
                    cell.profileImageView.addGestureRecognizer(tapGesture)
                    
                    tapGesture.rx.event.bind(with: self) { owner, tap in
                        if element.creator._id == UserDefaultsManager.userID {
                            let vc = ProfileViewController()
                            owner.transition(viewController: vc, style: .push)
                        } else {
                            let follwSheetVC = FollowViewController()
                            follwSheetVC.viewModel.postUserId = element.creator._id
                            owner.makeCustomSheetPresentationController(sheetVC: follwSheetVC)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                    
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
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("likeVCUpdateData"),
                                    object: nil,
                                    userInfo: ["isUpdate": true]
                                )
                                
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
                                
                                owner.viewModel.postListDataSource[row].comments.insert(newComment, at: 0)
                            }
                            let postList = owner.viewModel.postListDataSource[row]
                            vc.viewModel.postId = postList._id
                            vc.viewModel.postList = postList
                            owner.transition(viewController: vc, style: .presentNavigation)
                        }
                        .disposed(by: cell.disposeBag)
                    
                    // 더보기 버튼
                    cell.moreInfoButton.rx.tap
                        .observe(on: MainScheduler.instance)
                        .bind(with: self) { owner, _ in
                            if element.creator._id == UserDefaultsManager.userID {
                                let bottomSheetVC = PostListBottomSheetViewController()
                                bottomSheetVC.completion = { isDeleted in
                                    if isDeleted {
                                        owner.viewModel.updateDateSource()
                                    }
                                }
                                
                                bottomSheetVC.postUpdateCompletion = { postUpdateData in
                                    
                                    for (index, item) in owner.viewModel.postListDataSource.enumerated() {
                                        if item._id == postUpdateData._id {
                                            owner.viewModel.postListDataSource[index] = postUpdateData
                                            owner.viewModel.postListItem.onNext(owner.viewModel.postListDataSource)
                                        }
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
                    
                    cell.delegate = self
                }
                .disposed(by: disposeBag)
        
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
            
            model.comments = owner.viewModel.postListDataSource[indexPath.row].comments
            let vc = PostDetailViewController()
            
            vc.commentCreateCompletion = { [weak self] (id, newComment) in
                guard let self = self else { return }
                for (index, item) in self.viewModel.postListDataSource.enumerated() {
                    if item._id == id {
                        self.viewModel.postListDataSource[index].comments.insert(newComment, at: 0)
                        self.viewModel.postListItem.onNext(self.viewModel.postListDataSource)
                    }
                }
            }
            
            vc.viewModel.postList = model
            owner.transition(viewController: vc, style: .push)
        }
        .disposed(by: disposeBag)
        
    }
}



extension PostListViewController: CustomTableViewCellDelegate {
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

extension PostListViewController {
    private func configureNavigationBar() {
        navigationItem.title = "FLOW"
        setNavigationBarBackButtonItem(
            title: "",
            color: UIColor(resource: .tint)
        )
    }
}


