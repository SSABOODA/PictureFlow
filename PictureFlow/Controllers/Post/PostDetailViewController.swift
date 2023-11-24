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

final class PostDetailViewController: UIViewController {
    
    var viewModel = PostDetailViewModel()
    let mainView = PostDetailView()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .backgorund)
        print(viewModel.postItem)
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    func sizeHeaderToFit() {
        if let headerView = mainView.commentTableView.tableHeaderView {
            
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var newFrame = headerView.frame
            
            if height != newFrame.size.height {
                newFrame.size.height = height
                headerView.frame = newFrame
                
                mainView.commentTableView.tableHeaderView = headerView
            }
        }
    }
    
    private func bind() {
        
        // 테이블뷰 테스트
        let items = Observable.just(
            (0..<20).map { "\($0)" }
        )
        
        items.bind(to: mainView.commentTableView.rx.items(cellIdentifier: CommentTableViewCell.description(), cellType: CommentTableViewCell.self)) { (row, element, cell) in
        }
        .disposed(by: disposeBag)
        
        
        let input = PostDetailViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.postItem
            .subscribe(with: self) { owner, item in
                print("binding")
                let timeContent = DateTimeInterval.shared.calculateDateTimeInterval(createdTime: item.time)
                
                owner.mainView.headerView.nicknameLabel.text = item.creator.nick
                owner.mainView.headerView.contentLabel.text = item.content
                owner.mainView.headerView.postCreatedTimeLabel.text = timeContent
                if !item.image.isEmpty {
                    let imageURL = "\(BaseURL.baseURL)/\(item.image[0])"
                    imageURL.loadImageByKingfisher(imageView: owner.mainView.headerView.profileImageView)
                    owner.collectionViewBind(imageList: item.image)
                }
                owner.mainView.headerView.commentCountButton.setTitle("\(item.comments.count) 답글", for: .normal)
                owner.mainView.headerView.likeCountButton.setTitle("\(item.likes.count) 좋아요", for: .normal)
            }
            .disposed(by: disposeBag)
        
        // 최초 바인딩
        if let data = viewModel.postList {
            viewModel.postItem.onNext(data)
        }
    }
    
    private func collectionViewBind(imageList: [String]) {
        
//        mainView.collectionView.snp.updateConstraints { make in
//            make.height.equalTo(200)
//        }
        
//        sizeHeaderToFit()
        
        Observable.just(imageList)
            .bind(to: mainView.headerView.collectionView.rx.items(
                cellIdentifier: PostListCollectionViewCell.description(),
                cellType: PostListCollectionViewCell.self)
            ) { (row, element, cell) in
                let imageURL = "\(BaseURL.baseURL)/\(element)"
                imageURL.loadImageByKingfisher(imageView: cell.postImageView)
            }
            .disposed(by: disposeBag)
    }
    
}
