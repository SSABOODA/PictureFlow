//
//  WriteViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/22/23.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa

struct PostCreateModel: Identifiable, Hashable {
    let id = UUID()
}

final class PostWriteViewController: UIViewController, UIScrollViewDelegate {
    
    private enum Section: CaseIterable {
        case main
    }
    
    let mainView = PostWriteView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, PostCreateModel>!
    
    var photoImageList = [UIImage]()
    var photoImageObservableList = BehaviorSubject<[UIImage]>(value: [])
    let disposeBag = DisposeBag()
    
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
        
        mainView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
}

// configureDataSource
extension PostWriteViewController {
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PostWriteCollectionViewCell, PostCreateModel> { cell, indexPath, itemIdentifier in
            
//            cell.collectionView.delegate = nil
//            cell.collectionView.dataSource = nil
            
            print("cell registration")
            
            cell.addImageButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.addImageButtonClicked()
                }
                .disposed(by: cell.disposeBag)
            
            self.photoImageObservableList
                .bind(to: cell.collectionView.rx.items(
                    cellIdentifier: PostListCollectionViewCell.description(),
                    cellType: PostListCollectionViewCell.self)) { (row, element, innerCell) in
                        print("⭐️ rx element: \(element)")
                        
//                        cell.collectionView.snp.updateConstraints { make in
//                            make.height.equalTo(200)
//                        }
//                        cell.collectionView.layoutIfNeeded()
                     
                        innerCell.postImageView.image = element
                }
                .disposed(by: cell.disposeBag)

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
    
//    @objc 
    func addImageButtonClicked() {
        print(#function)
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5 // 제한 없을 경우 0
        configuration.filter = .any(of: [.images, .videos])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
}

// PHPickerViewControllerDelegate
extension PostWriteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        print(#function)
        
        if !results.isEmpty {
            photoImageList.removeAll()
            print("======photoImageList: \(photoImageList)")
            for result in results {
                let itemProvider = result.itemProvider
                print("======itemProvider: \(itemProvider)")
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        guard let image = image as? UIImage else { return }
                        print("🔥 image: \(image)")
                        DispatchQueue.main.async {
                            self?.photoImageList.append(image)
                        }
                        self?.photoImageObservableList.onNext(self?.photoImageList ?? [])
                    }
                }
            }
        }
    }
}

// Navigation
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

        self.showAlertAction2(title: "게시글 작성을 취소하시겠습니까?") {
            print("")
        } _: {
            let vc = CustomTabBarController()
            self.changeRootViewController(viewController: vc)
        }

        
        
    }
    
    @objc func plusButtonClicked() {
        print("photoImageList: \(photoImageList)")
        self.createList.append(PostCreateModel())
        self.performSnapshot()
    }
}

