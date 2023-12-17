//
//  CommentCreateViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/2/23.
//

import UIKit
import RxSwift
import RxCocoa

class CommentCreateViewController: UIViewController {
    
    let mainView = CommentCreateView()
    let viewModel = CommentCreateViewModel()
    var disposeBag = DisposeBag()
    var completionHandler: ((Comments) -> Void)?
    
    let maxCharacterCount = 300
    let showLimitCharacterCount = 50
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTextView()
        bind()
        viewModel.fetchProfilData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.commentTextView.becomeFirstResponder()
    }
    
    private func bind() {
        guard let rightBarButton = navigationItem.rightBarButtonItem else { return }
        
        let input = CommentCreateViewModel.Input(
            commentCreateButtonTap: rightBarButton.rx.tap,
            commentCreateContentText: mainView.commentTextView.rx.text.orEmpty
        )
        
        let output = viewModel.transform(input: input)
        
        output.errorResponse
            .subscribe(with: self) { owner, error in
                owner.showAlertAction1(message: error.message)
            }
            .disposed(by: disposeBag)
        
        output.userProfileObservable
            .subscribe(with: self) { owner, userProfile in
                owner.mainView.nicknameLabel.text = userProfile.nick
                
                if let profileImageURL = userProfile.profile {
                    profileImageURL.loadProfileImageByKingfisher(imageView: owner.mainView.profileImageView)
                }
            }
            .disposed(by: disposeBag)
        
        output.commentsObservableInfo
            .subscribe(with: self) { owner, newComment in
                owner.completionHandler?(newComment)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func configureTextView() {
        textViewDynamicHeight()
        
        mainView.commentTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.commentTextView.text) == "답글을 남겨보세요..." {
                    owner.mainView.commentTextView.text = nil
                    owner.mainView.commentTextView.textColor = UIColor(resource: .text)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.commentTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.commentTextView.text) == nil ||  (owner.mainView.commentTextView.text) == "" {
                    owner.mainView.commentTextView.text = "답글을 남겨보세요..."
                    owner.mainView.commentTextView.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
        
        
        mainView.commentTextView.rx.didChange
            .withLatestFrom(self.mainView.commentTextView.rx.text.orEmpty) { _, text -> Bool in
                
                if text.count > self.maxCharacterCount {
                    self.mainView.commentTextView.text = String(text.prefix(self.maxCharacterCount))
                    return false
                }
                return true
            }
            .bind(with: self) { owner, isMax in
            }
            .disposed(by: disposeBag)
        
        mainView.commentTextView.rx.text.orEmpty
            .map { text in
                if text == "답글을 남겨보세요..." {
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
            .bind(to: self.mainView.commentContentLimitCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        
    }
    
    func textViewDynamicHeight() {
        mainView.commentTextView.becomeFirstResponder()
        mainView.commentTextView.rx.didChange
            .withLatestFrom(mainView.commentTextView.rx.text)
            .bind(with: self) { owner, text in
                let size = CGSize(width: owner.view.frame.width, height: .infinity)
                let estimatedSize = owner.mainView.commentTextView.sizeThatFits(size)
                
                owner.mainView.commentTextView.constraints.forEach { (constraint) in
                    /// 180 이하일때는 더 이상 줄어들지 않게하기
                    if estimatedSize.height <= 180 {
                        
                    } else {
                        if constraint.firstAttribute == .height {
                            constraint.constant = estimatedSize.height
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// 네비게이션 세팅
extension CommentCreateViewController {
    private func configureNavigationBar() {
        navigationItem.title = "답글 달기"
        
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
        self.showAlertAction2(title: "답글 작성을 취소하시겠습니까?") {
        } _: {
            self.dismiss(animated: true)
        }
    }
    
    @objc func plusButtonClicked() {
        
    }
}
