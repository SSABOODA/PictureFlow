//
//  WriteViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/22/23.
//

import UIKit
import RxSwift
import RxCocoa

struct PostCreateModel: Identifiable, Hashable {
    let id = UUID()
}

final class PostWriteViewController: UIViewController {
    
    private enum Section: CaseIterable {
        case main
    }
    
    let mainView = PostWriteView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, PostCreateModel>!
    
    var createList = [
        PostCreateModel(),
    ]
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        configureDataSource()
        
        
    }
}

// configureDataSource
extension PostWriteViewController {
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PostWriteCollectionViewCell, PostCreateModel> { cell, indexPath, itemIdentifier in
            print(cell, indexPath)
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: self.mainView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        })
        
        self.performSnapshot()
    }
    
    private func performSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostCreateModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(createList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// 네비게이션 바
extension PostWriteViewController {
    private func configureNavigationBar() {
        navigationItem.title = "새로운 글 작성"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonClicked)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(plusButtonClicked)
        )
        navigationItem.rightBarButtonItem?.tintColor = UIColor(resource: .tint)
    }
    
    @objc func cancelButtonClicked() {
        print(#function)
        
        self.showAlertAction2(title: "게시글 작성을 취소하시겠습니까?",  {
            print("게시글 화면으로")
        })
    }
    
    @objc func plusButtonClicked() {
        self.createList.append(PostCreateModel())
        self.performSnapshot()
    }
}
