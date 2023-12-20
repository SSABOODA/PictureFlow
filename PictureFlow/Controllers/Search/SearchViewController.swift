//
//  SearchViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit
import RxSwift

final class SearchViewController: UIViewController {
    let mainView = SearchView()
    let viewModel = SearchViewModel()
    var disposeBag = DisposeBag()
    
    var hashTagWord: String = ""

    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchController()
        bindingRefreshControl()
        bind()
        dataBinding()

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
        guard let searchText = mainView.searchController.searchBar.text else { return }
        if isUpdate {
            self.viewModel.hashTagWord.onNext(searchText.removeHashTag())
        }
    }
    
    private func dataBinding() {
        if !self.hashTagWord.isEmpty {
            let word = hashTagWord.removeHashTag()
            viewModel.hashTagWord.onNext(word)
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
        let input = SearchViewModel.Input(
            searchBarSearchButtonTap: mainView.searchController.searchBar.rx.searchButtonClicked,
            searchText: mainView.searchController.searchBar.rx.text.orEmpty
        )
        let output = viewModel.transform(input: input)
        
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
        
        // pagination
        mainView.tableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .withUnretained(self)
            .bind(with: self) { owner, rowSet in
                let row = rowSet.1
                guard row <= owner.viewModel.hashTagPostList.count - 2 else { return }
                guard let searchText = self.mainView.searchController.searchBar.text else { return }
                
                let nextCursor = owner.viewModel.nextCursor
                if nextCursor != "0" {
                    owner.viewModel.prefetchData(
                        next: nextCursor,
                        hashTag: searchText.removeHashTag()
                    )
                }
            }
            .disposed(by: disposeBag)
        
        output.hashTagPostListObservable
            .bind(with: self) { owner, postList in
                owner.mainView.emptyLabel.isHidden = postList.isEmpty ? false : true
            }
            .disposed(by: disposeBag)
        
        output.hashTagPostListObservable
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
                                postId: self.viewModel.hashTagPostList[row]._id
                            )
                        )
                    }
                    .observe(on: MainScheduler.instance)
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            if data.likeStatus {
                                owner.viewModel.hashTagPostList[row].likes.append(UserDefaultsManager.userID)
                                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                cell.likeButton.tintColor = .red
                                likeCount += 1
                            } else {
                                if let index = owner.viewModel.hashTagPostList[row].likes.firstIndex(of: UserDefaultsManager.userID) {
                                    owner.viewModel.hashTagPostList[row].likes.remove(at: index)
                                }
                                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                cell.likeButton.tintColor = UIColor(resource: .tint)
                                if likeCount >= 1 { likeCount -= 1 }
                            }
                            owner.viewModel.hashTagPostListObservable.onNext(owner.viewModel.hashTagPostList)
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
                            owner.viewModel.hashTagPostList[row].comments.insert(newComment, at: 0)
                        }
                        let postList = owner.viewModel.hashTagPostList[row]
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
                                owner.viewModel.hashTagPostList[row] = postUpdateData
                                owner.viewModel.hashTagPostListObservable.onNext(owner.viewModel.hashTagPostList)
                            }
                            
                            bottomSheetVC.post = owner.viewModel.hashTagPostList[row]
                            bottomSheetVC.postId = owner.viewModel.hashTagPostList[row]._id
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
            
            model.comments = owner.viewModel.hashTagPostList[indexPath.row].comments
            let vc = PostDetailViewController()
            vc.commentCreateCompletion = { [weak self] (id, newComment) in
                guard let self = self else { return }
                for (index, item) in self.viewModel.hashTagPostList.enumerated() {
                    if item._id == id {
                        self.viewModel.hashTagPostList[index].comments.insert(newComment, at: 0)
                        self.viewModel.hashTagPostListObservable.onNext(self.viewModel.hashTagPostList)
                    }
                }
            }
            vc.viewModel.postList = model
            owner.transition(viewController: vc, style: .push)
        }
        .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController: CustomTableViewCellDelegate {
    func didTapHashTag(in cell: PostListTableViewCell, hashTagWord: String) {
    }
    
    func didTapButton(in cell: PostListTableViewCell, image: UIImage) {
        let vc = FullScreenImageViewController(image: image)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchControllerDelegate, UISearchBarDelegate {
    private func configureNavigationBar() {
        navigationItem.title = "검색"
        setNavigationBarBackButtonItem(color: UIColor(resource: .text))
    }
    
    private func configureSearchController() {
        self.mainView.searchController.searchBar.delegate = self
        self.navigationItem.searchController = mainView.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false

        if !self.hashTagWord.isEmpty {
            self.mainView.searchController.searchBar.text = self.hashTagWord
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let cancelButton = searchBar.value(forKey: "cancelButton") as! UIButton
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(UIColor(resource: .text), for: .normal)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension SearchViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.mainView.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return self.postViewControllerModalPresent(viewController: viewController)
    }
}
