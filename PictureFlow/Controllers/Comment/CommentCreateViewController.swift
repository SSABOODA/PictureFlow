//
//  CommentCreateViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/2/23.
//

import UIKit
import RxSwift

final class CommentCreateViewController: UIViewController {
    
    let mainView = CommentCreateView()
    let viewModel = CommentCreateViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.commentTextView.delegate = self
        configureNavigationBar()
        bind()
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
        
        output.commentCreateSuccess
            .subscribe(with: self) { owner, value in
                if value {
                    owner.dismiss(animated: true)
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
        print(#function)

        self.showAlertAction2(title: "답글 작성을 취소하시겠습니까?") {
            print("")
        } _: {
            self.dismiss(animated: true)
        }
    }
    
    @objc func plusButtonClicked() {
        
    }
}

extension CommentCreateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            /// 180 이하일때는 더 이상 줄어들지 않게하기
            if estimatedSize.height <= 180 {
                
            } else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
    }
}
