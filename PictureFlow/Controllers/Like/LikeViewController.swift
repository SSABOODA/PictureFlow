//
//  LikeViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit
import RxSwift

final class LikeViewController: UIViewController {
    
    let mainView = LikeView()
    let viewModel = LikeViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchUpdateDataSource()
    }
    
    private func bind() {
        let input = LikeViewModel.Input()
        let output = viewModel.transform(input: input)
        output.errorResponse
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
            }
            .disposed(by: disposeBag)
        
        output.likedPostListObservable
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
                                postId: self.viewModel.likedPostList[row]._id
                            )
                        )
                    }
                    .observe(on: MainScheduler.instance)
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            print("like network data: \(data)")

                            if data.likeStatus {
                                owner.viewModel.likedPostList[row].likes.append(UserDefaultsManager.userID)
                                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                cell.likeButton.tintColor = .red
                                likeCount += 1
                            } else {
                                if let index = owner.viewModel.likedPostList[row].likes.firstIndex(of: UserDefaultsManager.userID) {
                                    owner.viewModel.likedPostList[row].likes.remove(at: index)
                                }
                                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                cell.likeButton.tintColor = UIColor(resource: .tint)
                                if likeCount >= 1 { likeCount -= 1 }
                            }
                            owner.viewModel.likedPostListObservable.onNext(owner.viewModel.likedPostList)
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
                        let postList = owner.viewModel.likedPostList[row]
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
                                    owner.viewModel.fetchUpdateDataSource()
                                }
                            }
                            bottomSheetVC.post = owner.viewModel.likedPostList[row]
                            bottomSheetVC.postId = owner.viewModel.likedPostList[row]._id
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
        
        viewModel.fetchUpdateDataSource()
    }
}

extension LikeViewController {
    private func configureNavigationBar() {
        navigationItem.title = "좋아요"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.setNavigationBarBackButtonItem(title: "뒤로", color: UIColor(resource: .text))
    }
}
