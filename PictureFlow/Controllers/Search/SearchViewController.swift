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
        bind()
        dataBinding()
        print("서치뷰: \(hashTagWord)")
    }
    
    private func dataBinding() {
        if !self.hashTagWord.isEmpty {
            let word = hashTagWord.removeHashTag()
            viewModel.hashTagWord.onNext(word)
        }
    }
    
    private func bind() {
        let input = SearchViewModel.Input(
            searchBarSearchButtonTap: mainView.searchController.searchBar.rx.searchButtonClicked,
            searchText: mainView.searchController.searchBar.rx.text.orEmpty
        )
        let output = viewModel.transform(input: input)
        
        // pagination
        mainView.tableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .withUnretained(self)
            .bind(with: self) { owner, rowSet in
                let row = rowSet.1
                guard row == owner.viewModel.hashTagPostList.count - 1 else { return }
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
            .bind(to: mainView.tableView.rx.items(cellIdentifier: PostListTableViewCell.description(), cellType: PostListTableViewCell.self)) { (row, element, cell) in
                
                // cell 데이터 구성
                cell.configureCell(with: element)
                
                // 팔로우 버튼
                cell.profileFlollowCheckButtonView.isHidden = element.creator._id == UserDefaultsManager.userID ? true : false

                let tapGesture = UITapGestureRecognizer()
                cell.profileImageView.addGestureRecognizer(tapGesture)
                
                tapGesture.rx.event.bind(with: self) { owner, tap in
                    print("image view did tapppp")
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
                            print("like network data: \(data)")

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
                        print("post list view more button did tap")
                        if element.creator._id == UserDefaultsManager.userID {
                            let bottomSheetVC = PostListBottomSheetViewController()
                            bottomSheetVC.completion = { isDeleted in
                                if isDeleted {
                                    owner.viewModel.updateDateSource()
                                }
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
                
            }
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
            }
            .disposed(by: disposeBag)
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




