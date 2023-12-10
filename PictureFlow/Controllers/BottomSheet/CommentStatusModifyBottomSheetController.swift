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
            }
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: CommentDeleteResponse.self,
                    router: .commentDelete(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        postId: self.postId ?? "",
                        commentId: self.commentId ?? ""
                    )
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    print(data)
                    owner.completionHandler?(data)
                case .failure(let error):
                    print(error)
//                    owner.completionHandler?(false)
                }
            }
            .disposed(by: disposeBag)
  
    }
    
}

