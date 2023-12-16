//
//  CommentStatusModifyBottomSheetController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/10/23.
//

import UIKit
import RxSwift

final class CommentStatusModifyBottomSheetController: BottomSheetViewController {
    let updateButton = {
        let button = UIButton()
        button.setTitle("수정", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(UIColor(resource: .text), for: .normal)
        button.backgroundColor = UIColor(resource: .postStatusModify)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    let deleteButton = {
        let button = UIButton()
        button.setTitle("삭제", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = UIColor(resource: .postStatusModify)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    var disposeBag = DisposeBag()
    var postId: String? = ""
    var commentId: String? = ""
    var post: PostList? = nil
    var comment: Comments? = nil
    var completionHandler: ((CommentDeleteResponse) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        configureHierarchy()
        configureLayout()
        bind()
    }
    
    private func configureHierarchy() {
        bottomSheetView.addSubview(updateButton)
        bottomSheetView.addSubview(deleteButton)
    }
    
    private func configureLayout() {
        updateButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalToSuperview().multipliedBy(0.25)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(updateButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(updateButton.snp.width)
            make.height.equalTo(updateButton.snp.height)
        }
    }
    
    private func bind() {
        updateButton.rx.tap
            .bind(with: self) { owner, _ in
                print("comment update button did tap")
                let vc = CommentUpdateViewController()
                vc.commentUpdateViewModel.post = owner.post
                vc.commentUpdateViewModel.comment = owner.comment
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind(with: self) { owner, _ in
                print("deleteButton did tap")
                
                owner.showAlertAction2(
                    title: "작성하신 댓글을 삭제하시겠어요?",
                    message: "댓글을 삭제하면 복원할 수 없습니다.", cancelTitle: "취소", completeTitle: "삭제") {
                    } _: {
                        print("삭제")
                        Network.shared.requestConvertible(
                            type: CommentDeleteResponse.self,
                            router: .commentDelete(
                                accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                                postId: self.postId ?? "",
                                commentId: self.commentId ?? ""
                            )
                        ) { response in
                            switch response {
                            case .success(let data):
                                print(data)
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("updateDataSource"),
                                    object: nil,
                                    userInfo: ["isUpdate": true]
                                )
                                owner.completionHandler?(data)
                            case .failure(let error):
//                                owner.completionHandler?(false)
                                owner.showAlertAction1(message: error.message)
                            }
                        }
                        
                    }
            }
            .disposed(by: disposeBag)
    }
    
}

