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
        
        _ = postUpdateViewModel.transform(input: PostUpdateViewModelInput)
        
        self.postUpdateViewModel.postUpdateResponse
            .subscribe(with: self) { owner, value in
                owner.dismiss(animated: true)
                NotificationCenter.default.post(
                    name: NSNotification.Name("oberservePostUpdate"),
                    object: nil,
                    userInfo: ["postData": value]
                )
            }
            .disposed(by: disposeBag)
    }
    
    func configurePostData() {
        guard let post = self.postUpdateViewModel.post else { return }
        self.mainView.postContentTextView.text = post.content
        
        let group = DispatchGroup()
        for imageString in post.image {
            group.enter()
            imageString.downloadImage(urlString: imageString) { [weak self] UIImage in
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
                if (owner.mainView.postContentTextView.text) == "게시글을 수정해보세요..." {
                    owner.mainView.postContentTextView.text = nil
                    owner.mainView.postContentTextView.textColor = UIColor(resource: .text)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.postContentTextView.text) == nil ||  (owner.mainView.postContentTextView.text) == "" {
                    owner.mainView.postContentTextView.text = "게시글을 수정해보세요..."
                    owner.mainView.postContentTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        let maxCharacterCount = 20
        
        mainView.postContentTextView.rx.didChange
            .withLatestFrom(self.mainView.postContentTextView.rx.text.orEmpty) { _, text -> Bool in
                
                if text.count > maxCharacterCount {
                    self.mainView.postContentTextView.text = String(text.prefix(maxCharacterCount))
                    return false
                }
                return true
            }
            .bind(with: self) { owner, isMax in
//                print("isMax: \(isMax)")
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.text.orEmpty
            .map { text in
                if text == "게시글을 수정해보세요..." {
                    return ""
                }
                let currentCount = text.count
                let limitCount = maxCharacterCount-currentCount
                if limitCount > 10 {
                    return ""
                } else if limitCount < 0 {
                    return "0"
                } else {
                    return "\(maxCharacterCount-currentCount)"
                }
            }
            .bind(to: self.mainView.postContentLimitCountLabel.rx.text)
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
