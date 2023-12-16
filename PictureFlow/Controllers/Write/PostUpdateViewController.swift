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
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("oberservePostUpdate"),
                    object: nil,
                    userInfo: ["postData": value]
                )
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("updateDataSource"),
                    object: nil,
                    userInfo: ["isUpdate": true]
                )
                
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func configurePostData() {
        guard let post = self.postUpdateViewModel.post else { return }
        self.mainView.postContentTextView.attributedText = self.processHashtags(in: post.content)
        
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
        
        // UITextView의 텍스트 변경을 감지
        mainView.postContentTextView.rx.didChange
            .map { [weak self] in self?.mainView.postContentTextView.text }
            .bind { [weak self] text in
                let att = self?.processHashtags(in: text)
                self?.mainView.postContentTextView.attributedText = att
                
            }
            .disposed(by: disposeBag)
        
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
        
        
        mainView.postContentTextView.rx.didChange
            .withLatestFrom(self.mainView.postContentTextView.rx.text.orEmpty) { _, text -> Bool in
                
                if text.count > self.maxCharacterCount {
                    self.mainView.postContentTextView.text = String(text.prefix(self.maxCharacterCount))
                    return false
                }
                return true
            }
            .bind(with: self) { owner, isMax in
            }
            .disposed(by: disposeBag)
        
        mainView.postContentTextView.rx.text.orEmpty
            .map { text in
                if text == "게시글을 수정해보세요..." {
                    return ""
                }
                let currentCount = text.count
                let limitCount = self.maxCharacterCount-currentCount
                if limitCount > self.showLimitCharacterCount {
                    return ""
                } else if limitCount < 0 {
                    return "0"
                } else {
                    return "\(self.maxCharacterCount-currentCount)"
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
