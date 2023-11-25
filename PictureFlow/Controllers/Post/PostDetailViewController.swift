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
    
    lazy var collectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.register(
            CommentCollectionViewCell.self,
            forCellWithReuseIdentifier: CommentCollectionViewCell.description()
        )
        collectionView.register(
            CommentCollectionReusableHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CommentCollectionReusableHeaderView.description()
        )
        
        collectionView.register(
            EmptyCommentCollectionReusableHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmptyCommentCollectionReusableHeaderView.description()
        )
        return collectionView
    }()

    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .backgorund)
        bind()
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemMint
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.rx.setDelegate(self)
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
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.postObservableItem.onNext(viewModel.postDataList)
        
        collectionView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                print(indexPath)
            }
            .disposed(by: disposeBag)
    }
    
    private func collectionViewBind(imageList: [String]) {
        
//        mainView.collectionView.snp.updateConstraints { make in
//            make.height.equalTo(200)
//        }
        
//        sizeHeaderToFit()
//        Observable.just(imageList)
//            .bind(to: mainView.collectionView.rx.items(
//                cellIdentifier: PostListCollectionViewCell.description(),
//                cellType: PostListCollectionViewCell.self)
//            ) { (row, element, cell) in
//                let imageURL = "\(BaseURL.baseURL)/\(element)"
//                imageURL.loadImageByKingfisher(imageView: cell.postImageView)
//            }
//            .disposed(by: disposeBag)
        
    }
    
}

// RxDataSource
extension PostDetailViewController {
    func configureRxCollectionViewDataSource() -> RxCollectionViewSectionedReloadDataSource<PostDetailModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<PostDetailModel> { (dataSource, collectionView, indexPath, data) in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.description(), for: indexPath) as? CommentCollectionViewCell else { return UICollectionViewCell() }
            print(data)
            cell.backgroundColor = .blue
//            cell.label.text = data
            return cell
            
        } configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) in
            
//            self.collectionView.delegate = nil
//            self.collectionView.dataSource = nil
            
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
    

    private func configureCollectionView(with imageList: [String]) {
        
    }
}

extension PostDetailViewController {
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.1)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let headerFooterSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(1.0)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        return layout
    }
}
