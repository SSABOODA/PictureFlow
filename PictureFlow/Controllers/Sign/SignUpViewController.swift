//
//  SignUpViewController.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SignUpViewController: UIViewController {
    
    let mainView = SignUpView()
    let viewModel = SignUpViewModel()
    var disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.emailTextField.becomeFirstResponder()
    }
    
    private func bind() {
        
        let input = SignUpViewModel.Input(
            email: mainView.emailTextField.rx.text.orEmpty,
            password: mainView.passwordTextField.rx.text.orEmpty,
            nickname: mainView.nicknameTextField.rx.text.orEmpty,
            phoneNumber: mainView.phoneNumberTextField.rx.text.orEmpty,
            birthday: mainView.birthdayTextField.rx.text.orEmpty,
            signUpButtonTap: mainView.signUpButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.validation
            .subscribe(with: self) { owner, value in
                let color = value ? UIColor.systemBlue : UIColor.lightGray
                owner.mainView.signUpButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        output.signUpSuccess
            .asDriver()
            .drive(with: self) { owner, value in
                print("signUpSuccess next VC")
            }
            .disposed(by: disposeBag)
        
    }
    
}
