//
//  PostUpdateViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/8/23.
//

import UIKit
import RxSwift
import RxCocoa


final class PostUpdateViewController: NewPostWriteViewController {
    var postUpdateViewModel = PostUpdateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        bind()
    }

    private func bind() {
        guard let rightBarPostUpdateButton = navigationItem.rightBarButtonItem else { return }

        let PostUpdateViewModelInput = PostUpdateViewModel.Input(
            rightBarPostUpdateButtonTap: rightBarPostUpdateButton.rx.tap,
            postUpdateContentText: self.mainView.postContentTextView.rx.text.orEmpty,
            image: self.viewModel.photoImageObservableList
        )
        let PostUpdateViewModelOutput = postUpdateViewModel.transform(input: PostUpdateViewModelInput)
        
        PostUpdateViewModelOutput.successPostCreate
            .bind(with: self) { owner, isCreated in
                if isCreated {
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        
    }
    
    func configurePostData() {
        guard let post = self.postUpdateViewModel.post else { return }
        self.mainView.postContentTextView.text = post.content
        
        let group = DispatchGroup()
        for imageString in post.image {
            let urlString = "\(BaseURL.baseURL)/\(imageString)"
            group.enter()
            urlString.downloadImage(urlString: urlString) { [weak self] UIImage in
                guard let image = UIImage else { return }
                
                self?.viewModel.photoImageList.append(image)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("✏️ END", self.viewModel.photoImageList)
            self.viewModel.photoImageObservableList.onNext(self.viewModel.photoImageList)
        }
    }
    
    override func configureTextView() {
        textViewDynamicHeight()
        
        mainView.postContentTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.postContentTextView.text) == "게시글 수정하기..." {
                    owner.mainView.postContentTextView.text = nil
                    owner.mainView.postContentTextView.textColor = UIColor(resource: .text)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.postContentTextView.text) == nil ||  (owner.mainView.postContentTextView.text) == "" {
                    owner.mainView.postContentTextView.text = "게시글 수정하기..."
                    owner.mainView.postContentTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func configureNavigation() {
        navigationItem.title = "게시글 수정"
        let postUpdateButton = UIBarButtonItem(
            title: "수정",
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.rightBarButtonItem = postUpdateButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(resource: .tint)
    }
}