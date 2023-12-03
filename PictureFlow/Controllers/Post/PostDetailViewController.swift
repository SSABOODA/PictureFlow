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
    
    var viewModel = PostDetailViewModel()
    let mainView = PostDetailView()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
        mainView.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private func bind() {
        let input = PostDetailViewModel.Input()
        let output = viewModel.transform(input: input)
         
        let dataSource = configureRxCollectionViewDataSource()
        
        output.postObservableItem
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
                print("답글 남기기 TAP")
                let vc = CommentCreateViewController()
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
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.description(), for: indexPath) as? CommentCollectionViewCell else { return UICollectionViewCell() }
        
            print("🔥", data)
            
            
            
            cell.nicknameLabel.text = data.creator.nick
            cell.commentContentLabel.text = data.content
            
//            let timeContent = DateTimeInterval.shared.calculateDateTimeInterval(createdTime: data.time)
            
            cell.commentCreatedTimeLabel.text = "99일 전"
            
            
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
                print("elements: \(elements)")
                
                // 시간 작업
                let timeContent = DateTimeInterval.shared.calculateDateTimeInterval(createdTime: elements.time)

                cell.nicknameLabel.text = elements.creator.nick
                cell.postCreatedTimeLabel.text = timeContent
                cell.contentLabel.text = elements.content
                if !elements.image.isEmpty {
                    let imageURL = "\(BaseURL.baseURL)/\(elements.image[0])"
                    imageURL.loadImageByKingfisher(imageView: cell.profileImageView)
                }
                
                cell.commentCountButton.setTitle("\(elements.comments.count) 답글", for: .normal)
                cell.likeCountButton.setTitle("\(elements.likes.count) 좋아요", for: .normal)
                
                /*
                 collectionView 작업
                 */
                
                let height = elements.image.isEmpty ? 0 : 200
                
                cell.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(height)
                }

                Observable.just(elements.image)
                    .bind(to: cell.collectionView.rx.items(cellIdentifier: PostListCollectionViewCell.description(), cellType: PostListCollectionViewCell.self)) { (row, element, cell) in
                        let imageURL = "\(BaseURL.baseURL)/\(element)"
                        imageURL.loadImageByKingfisher(imageView: cell.postImageView)
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

}

