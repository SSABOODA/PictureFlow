//
//  CommentUpdateViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/10/23.
//

import UIKit
import RxSwift
import RxCocoa

final class CommentUpdateViewModel: CommentCreateViewModel {
    struct Input {
        let commentUpdateBarButtonTap: ControlEvent<Void>
        let commentUpdateContentText: ControlProperty<String>
    }
    
    struct Output {
        let commentsObservableInfo: PublishSubject<Comments>
    }
    
    var post: PostList? = nil
    var comment: Comments? = nil

    func transform(input: Input) -> Output {
        input.commentUpdateBarButtonTap
            .withLatestFrom(input.commentUpdateContentText)
            .map {
                CommentUpdateRequest(content: $0)
            }
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: CommentUpdateResponse.self,
                    router: .commentUpdate(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        postId: self.post?._id ?? "",
                        commentId: self.comment?._id ?? "",
                        model: $0
                    )
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    print(data)
                    let updatedComment = Comments(
                        _id: data._id,
                        content: data.content,
                        time: data.time,
                        creator: data.creator
                    )
                    owner.commentsObservableInfo.onNext(updatedComment)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            commentsObservableInfo: commentsObservableInfo
        )
    }
}

final class CommentUpdateViewController: CommentCreateViewController {
    
    let commentUpdateViewModel = CommentUpdateViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureView()
        bind()
    }
    
    override func configureTextView() {
        textViewDynamicHeight()
        
        mainView.commentTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.commentTextView.text) == "답글을 수정해보세요..." {
                    owner.mainView.commentTextView.text = nil
                    owner.mainView.commentTextView.textColor = UIColor(resource: .text)
                }
            }
            .disposed(by: disposeBag)
        
        mainView.commentTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                if (owner.mainView.commentTextView.text) == nil ||  (owner.mainView.commentTextView.text) == "" {
                    owner.mainView.commentTextView.text = "답글을 수정해보세요..."
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
                if text == "답글을 수정해보세요..." {
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
    
    private func configureView() {
        guard let comment = self.commentUpdateViewModel.comment else { return }
        mainView.commentTextView.text = comment.content
    }
    
    private func bind() {
        guard let commentUpdateBarButton = navigationItem.rightBarButtonItem else { return }
        let input = CommentUpdateViewModel.Input(
            commentUpdateBarButtonTap: commentUpdateBarButton.rx.tap,
            commentUpdateContentText: self.mainView.commentTextView.rx.text.orEmpty
        )
        
        let ouput = commentUpdateViewModel.transform(input: input)
        ouput.commentsObservableInfo
            .subscribe(with: self) { owner, comment in
                owner.dismiss(animated: true)
                NotificationCenter.default.post(
                    name: NSNotification.Name("observeCommentUpdate"),
                    object: nil,
                    userInfo: ["commentData": comment]
                )
            }
            .disposed(by: disposeBag)
    }
    
}

// 네비게이션 세팅
extension CommentUpdateViewController {
    private func configureNavigationBar() {
        navigationItem.title = "답글 수정"
        
        // postCancelButton
        let postCancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(updateCancelButtonClicked)
        )
        navigationItem.leftBarButtonItem = postCancelButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
        
        // postCreateButton
        let postCreateButton = UIBarButtonItem(
            title: "수정",
            style: .plain,
            target: self,
            action: #selector(plusButtonClicked)
        )
        navigationItem.rightBarButtonItem = postCreateButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor(resource: .tint)
    }
    
    @objc func updateCancelButtonClicked() {
        print(#function)

        self.showAlertAction2(title: "답글 수정을 취소하시겠습니까?") {
            print("")
        } _: {
            self.dismiss(animated: true)
        }
    }
    
    
}
