//
//  LoginViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SignInViewController: UIViewController {
    
    let mainView = SignInView()
    let viewModel = SignInViewModel()
    let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        
        let isSecure = BehaviorRelay(value: true)
        let input = SignInViewModel.Input(
            email: mainView.emailTextField.rx.text.orEmpty,
            password: mainView.passwordTextField.rx.text.orEmpty,
            loginButtonTap: mainView.loginButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.validation
            .bind(to: mainView.loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.validation
            .subscribe(with: self) { owner, value in
                owner.mainView.loginButton.backgroundColor = value ? UIColor.systemBlue : UIColor.lightGray
            }
            .disposed(by: disposeBag)
        
        output.loginSuccess
            .asDriver()
            .map {
                return $0 == true
            }
            .drive(with: self) { owner, value in
                print("Login Succeed")
            }
            .disposed(by: disposeBag)
        
        mainView.passwordSecureButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.mainView.passwordTextField.isSecureTextEntry.toggle()
                isSecure.accept(owner.mainView.passwordTextField.isSecureTextEntry)
            }
            .disposed(by: disposeBag)
        
        isSecure
            .bind(with: self) { owner, value in
                print(value)
                let image = value ? "eye" : "eye.fill"
                let color = value ? UIColor.lightGray : UIColor.black
                owner.mainView.passwordSecureButton.setImage(UIImage(systemName: image), for: .normal)
                owner.mainView.passwordSecureButton.tintColor = color
            }
            .disposed(by: disposeBag)

    }
    
}
