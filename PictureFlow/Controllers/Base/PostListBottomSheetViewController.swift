//
//  PostListBottomSheetViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/8/23.
//

import UIKit
import RxSwift

final class PostListBottomSheetViewController: BottomSheetViewController {
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
    var postId: String = ""
    var post: PostList?
    var completion: ((Bool) -> Void)?
    
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
                print("updateButton did tap")
                let vc = PostWriteViewController()
                vc.viewModel.post = owner.post
                vc.configurePostData()
                owner.transition(viewController: vc, style: .presentNavigation)
            }
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap
            .bind(with: self) { owner, _ in
                print("deleteButton did tap")
                
                owner.showAlertAction2(
                    title: "게시물을 삭제하시겠어요?",
                    message: "게시물을 삭제하면 복원할 수 없습니다.", cancelTitle: "취소", completeTitle: "삭제") {
                        
                    } _: {
                        print("삭제")
                        
                        guard let post = owner.post else { return }
                        guard let token = KeyChain.read(key: APIConstants.accessToken) else { return }

                        Network.shared.requestConvertible(type: PostDeleteResponse.self, router: .postDelete(
                            accessToken: token,
                            postId: post._id)) { result in
                            switch result {
                            case .success(let data):
                                print(data)
                                owner.completion?(true)
                                owner.dismiss(animated: true)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
            }
            .disposed(by: disposeBag)
    }
}
