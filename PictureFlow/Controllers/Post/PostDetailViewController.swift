//
//  PostViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class PostDetailViewController: UIViewController, UIScrollViewDelegate {
    
    let mainView = PostDetailView()
    var viewModel = PostDetailViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
        mainView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
    }
    
    private func bind() {
        let input = PostDetailViewModel.Input()
        let output = viewModel.transform(input: input)
         
        let dataSource = configureRxCollectionViewDataSource()

        output.postObservableItem
            .observe(on: MainScheduler.instance)
            .bind(to: mainView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.postObservableItem.onNext(viewModel.postDataList)
        
        mainView.collectionView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                print(indexPath)
            }
            .disposed(by: disposeBag)
        
        mainView.commentInputButton.rx.tap
            .bind(with: self) { owner, _ in
                print("답글 남기기 버튼 TAP")
                let vc = CommentCreateViewController()
                vc.completionHandler = { newComment in
                    print("newComment: \(newComment)")
                    owner.viewModel.postDataList[0].items.insert(newComment, at: 0)
                    owner.viewModel.postObservableItem.onNext(owner.viewModel.postDataList)
                }
                
                guard let post = self.viewModel.postList else { return }
                vc.viewModel.postId = post._id
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
    }
}

// RxDataSource
extension PostDetailViewController {
    private func configureRxCollectionViewDataSource() -> RxCollectionViewSectionedReloadDataSource<PostDetailModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<PostDetailModel> { (dataSource, collectionView, indexPath, data) in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.description(), for: indexPath) as? CommentCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.nicknameLabel.text = data.creator.nick
            cell.commentContentLabel.text = data.content
            let timeContent = DateTimeInterval.shared.calculateDateTimeInterval(createdTime: data.time)
            cell.commentCreatedTimeLabel.text = timeContent
            
            cell.moreInfoButton.rx.tap
                .bind(with: self) { owner, _ in
                    print("more button did tap")
                    let bottomSheetVC = CommentStatusModifyBottomSheetController()
                    
                    if let postInfo = owner.viewModel.postDataList.first {
                        bottomSheetVC.postId = postInfo.header._id
                        bottomSheetVC.commentId = postInfo.items[indexPath.row]._id
                        bottomSheetVC.post = postInfo.header
                        bottomSheetVC.comment = postInfo.items[indexPath.row]
                        bottomSheetVC.completionHandler = { commentDeleteResponse in
                            for (idx, item) in self.viewModel.postDataList[0].items.enumerated() {
                                if item._id == commentDeleteResponse.commentId {
                                    self.viewModel.postDataList[0].items.remove(at: idx)
                                    self.viewModel.postObservableItem.onNext(self.viewModel.postDataList)
                                }
                            }
                        }
                        
                        NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(owner.observeCommentUpdate(_:)),
                            name: NSNotification.Name("observeCommentUpdate"),
                            object: nil
                        )
                        
                        bottomSheetVC.modalPresentationStyle = .overFullScreen
                        self.present(bottomSheetVC, animated: false)
                    }

                }
                .disposed(by: cell.disposeBag)
            
            return cell
            
        } configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) in
            /*
             HeaderView 작업
             */
            if kind == UICollectionView.elementKindSectionHeader, indexPath.section == 0 {
                guard let cell = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CommentCollectionReusableHeaderView.description(),
                    for: indexPath
                ) as? CommentCollectionReusableHeaderView else {
                    return UICollectionReusableView()
                }
                
                /*
                 Cell 데이터 작업
                 */
                let elements = dataSource[indexPath.section].header
                
                // 시간 작업
                let timeContent = DateTimeInterval.shared.calculateDateTimeInterval(createdTime: elements.time)
                
                cell.nicknameLabel.text = elements.creator.nick
                cell.postCreatedTimeLabel.text = timeContent
                cell.contentLabel.text = elements.content
                
                if !elements.image.isEmpty {
                    let imageURL = elements.image[0]
                    imageURL.loadImageByKingfisher(imageView: cell.profileImageView)
                }
                
                cell.commentCountButton.setTitle("\(elements.comments.count) 답글", for: .normal)
                cell.likeCountButton.setTitle("\(elements.likes.count) 좋아요", for: .normal)
                
                // 좋아요
                var likeCount = elements.likes.count

                let userId = UserDefaultsManager.userID
                if elements.likes.contains(userId) {
                    cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    cell.likeButton.tintColor = .red
                } else {
                    cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    cell.likeButton.tintColor = UIColor(resource: .tint)
                }
                
                cell.likeCountButton.setTitle("\(likeCount) 좋아요", for: .normal)
                
                // 좋아요 버튼
                cell.likeButton.rx.tap
                    .throttle(.seconds(1), scheduler: MainScheduler.instance)
                    .flatMap {
                        Network.shared.requestObservableConvertible(
                            type: LikeRetrieveResponse.self,
                            router: .like(
                                accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                                postId: elements._id
                            )
                        )
                    }
                    .observe(on: MainScheduler.instance)
                    .bind(with: self) { owner, result in
                        print("like button tap")
                        switch result {
                        case .success(let data):
                            print("like network data: \(data.likeStatus)")
                            if data.likeStatus {
                                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                                cell.likeButton.tintColor = .red
                                likeCount += 1
                            } else {
                                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                                cell.likeButton.tintColor = UIColor(resource: .tint)
                                if likeCount >= 1 { likeCount -= 1 }
                            }
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
                        vc.completionHandler = { newComment in
                            owner.viewModel.postDataList[0].items.insert(newComment, at: 0)
                            owner.viewModel.postObservableItem.onNext(owner.viewModel.postDataList)
                        }
                        vc.viewModel.postId = elements._id
                        owner.transition(viewController: vc, style: .presentNavigation)
                    }
                    .disposed(by: cell.disposeBag)
                
                // 더보기 버튼
                cell.moreInfoButton.rx.tap
                    .observe(on: MainScheduler.instance)
                    .bind(with: self) { owner, _ in
                        print("post detail view more button did tap")
                        let bottomSheetVC = PostListBottomSheetViewController()
                        bottomSheetVC.modalPresentationStyle = .overFullScreen
                        self.present(bottomSheetVC, animated: false)
                        
                        bottomSheetVC.completion = { isDeleted in
                            if isDeleted {
                                owner.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                        NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(owner.oberservePostUpdate(_:)),
                            name: NSNotification.Name("oberservePostUpdate"),
                            object: nil
                        )

                        let post = owner.viewModel.postDataList[indexPath.row].header
                        bottomSheetVC.post = post
                        bottomSheetVC.postId = post._id
                    }
                    .disposed(by: cell.disposeBag)
                
                /*
                 collectionView 작업
                 */
                
                cell.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(elements.image.isEmpty ? 0 : 200)
                }
                
                cell.collectionView.delegate = nil
                cell.collectionView.dataSource = nil
                
                Observable.just(elements.image)
                    .bind(to: cell.collectionView.rx.items(
                        cellIdentifier: BasePostListImageCollectionViewCell.description(),
                        cellType: BasePostListImageCollectionViewCell.self)) { (row, element, cell) in
                            element.loadImageByKingfisher(imageView: cell.postImageView)
                    }
                    .disposed(by: self.disposeBag)
                
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: EmptyCommentCollectionReusableHeaderView.description(),
                    for: indexPath
                ) as? EmptyCommentCollectionReusableHeaderView else {
                    return UICollectionReusableView()
                }
                return cell
            }
        }
        return dataSource
    }
    
    @objc func oberservePostUpdate(_ notification:NSNotification) {
        guard let passedPostData = notification.userInfo else { return }
        guard let postData = passedPostData["postData"] as? PostUpdateResponse else { return }
        
        let postListItem = PostList(
            _id: postData._id,
            likes: postData.likes,
            image: postData.image,
            content: postData.content,
            time: postData.time,
            productID: postData.productID,
            creator: postData.creator,
            comments: postData.comments
        )
        
        self.viewModel.postDataList[0].header = postListItem
        self.viewModel.postDataList[0].items = postListItem.comments
        self.viewModel.postObservableItem.onNext(self.viewModel.postDataList)
    }
    
    @objc func observeCommentUpdate(_ notification:NSNotification) {
        guard let passedCommentData = notification.userInfo else { return }
        guard let commentData = passedCommentData["commentData"] as? Comments else { return }
        
        for (idx, item) in self.viewModel.postDataList[0].items.enumerated() {
            if item._id == commentData._id {
                self.viewModel.postDataList[0].items[idx].content = commentData.content
            }
        }
        
        self.viewModel.postObservableItem.onNext(self.viewModel.postDataList)
    }
}
