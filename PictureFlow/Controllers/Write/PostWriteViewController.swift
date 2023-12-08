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

struct PostCreateModel: Hashable {
    let _id: String
    let content: String
    let imageList: [String]
}

final class PostWriteViewController: UIViewController, UIScrollViewDelegate {
    
    private enum Section: CaseIterable {
        case main
    }
    
    let mainView = PostWriteView()
    let viewModel = PostWriteViewModel()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PostCreateModel>!
    
    var createList = [
        PostCreateModel(
            _id: "",
            content: "", 
            imageList: []
        )
    ]
    
    let disposeBag = DisposeBag()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mainView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        configureNavigationBar()
        configureDataSource()
        bind()
        configureView()
    }
    
    func configurePostData() {
        guard let post = self.viewModel.post else { return }
        let postData = PostCreateModel(
            _id: post._id,
            content: post.content ?? "",
            imageList: post.image
        )
        
        createList.removeAll()
        createList.append(postData)
        
        let group = DispatchGroup()
        var postImageList = [UIImage]()
        
        
        for imageString in post.image {
            let urlString = "\(BaseURL.baseURL)/\(imageString)"
            print("urlString: \(urlString)")
            
            group.enter()
            urlString.downloadImage(urlString: urlString) { UIImage in
                guard let image = UIImage else { return }
                postImageList.append(image)
                print("postImageList: \(postImageList)")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("END")
            print("✏️", postImageList)
            self.viewModel.photoImageObservableList.onNext(postImageList)
        }
        
    }
 
    private func bind() {
        
    }
    
    private func configureView() {
        
    }
}

// configureDataSource
extension PostWriteViewController {
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PostWriteCollectionViewCell, PostCreateModel> { [weak self] cell, indexPath, itemIdentifier in
            
            guard let self else { return }
            guard let rightBarButton = navigationItem.rightBarButtonItem else { return }
            
            print("cell registration")
            
            if !itemIdentifier.content.isEmpty {
                cell.postContentTextField.text = itemIdentifier.content
            }
            
            cell.addImageButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.addImageButtonClicked()
                }
                .disposed(by: cell.disposeBag)
            
            let input = PostWriteViewModel.Input(
                postCreateButtonTap: rightBarButton.rx.tap,
                postContentText: cell.postContentTextField.rx.text.orEmpty
            )
            
            let output = viewModel.transform(input: input)
            
            output.photoImageObservableList
                .bind(to: cell.collectionView.rx.items(
                    cellIdentifier: PostListImageCancelCollectionViewCell.description(),
                    cellType: PostListImageCancelCollectionViewCell.self)) { (row, element, innerCell) in
                        print("⭐️ rx element: \(element)")
                        innerCell.postImageView.image = element
                        innerCell.cancelButton.rx.tap
                            .bind(with: self) { owner, _ in
                                print("cancel button did tap")
                                
                                owner.viewModel.photoImageList.remove(at: row)
                                owner.viewModel.photoImageObservableList.onNext(owner.viewModel.photoImageList)
                            }
                            .disposed(by: innerCell.disposeBag)
                }
                .disposed(by: cell.disposeBag)
            
            output.successPostCreate
                .bind(with: self) { owner, isCreated in
                    if isCreated {
                        let vc = CustomTabBarController()
                        owner.changeRootViewController(viewController: vc)
                    }
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
    
    func performSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostCreateModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(createList)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// PHPickerViewControllerDelegate
extension PostWriteViewController: PHPickerViewControllerDelegate {
    private func addImageButtonClicked() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        print(#function)
        
        if !results.isEmpty {
            viewModel.photoImageList.removeAll()
            for result in results {
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        guard let image = image as? UIImage else { return }
                        print("🔥 image: \(image)")
                        DispatchQueue.main.async {
                            self?.viewModel.photoImageList.append(image)
                            self?.viewModel.photoImageObservableList.onNext(self?.viewModel.photoImageList ?? [])
                        }
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
        
        // postCancelButton
        let postCancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonClicked)
        )
        navigationItem.leftBarButtonItem = postCancelButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
        
        // postCreateButton
        let postCreateButton = UIBarButtonItem(
            title: "게시",
            style: .plain,
            target: self,
            action: #selector(plusButtonClicked)
        )
        navigationItem.rightBarButtonItem = postCreateButton
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
        // 셀 더하기
//        self.createList.append(PostCreateModel())
//        self.performSnapshot()
        
        // 게시글 작성 Create
//        viewModel.postCreateRequest()
        
        
    }

}

