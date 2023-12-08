//
//  PostWriteView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/27/23.
//

import UIKit

final class PostWriteView: UIView {
    lazy var collectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {
        addSubview(collectionView)
    }
    
    func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// collection layout
extension PostWriteView {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let heightDimension = NSCollectionLayoutDimension.estimated(500)
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: heightDimension
            )
            
            let item = NSCollectionLayoutItem(
                layoutSize: itemSize
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: heightDimension
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 5,
                leading: 20,
                bottom: 0,
                trailing: 20
            )
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider,
            configuration: config
        )
        
        return layout
    }
}
