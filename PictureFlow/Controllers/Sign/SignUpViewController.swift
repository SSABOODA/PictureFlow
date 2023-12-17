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
    private var diaryDate: Date?
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureDatePicker()
        configureTextField()
        bind()
    }
    
    @objc func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        self.diaryDate = datePicker.date
        self.mainView.birthdayTextField.text = datePicker.date.convertDateToString(format: .compact, localeType: .ko_KR)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.emailTextField.becomeFirstResponder()
    }
    
    func configureDatePicker() {
        mainView.datePicker.addTarget(
            self,
            action: #selector(datePickerValueDidChange(_:)),
            for: .valueChanged
        )
    }
    
    private func configureTextField() {
        mainView.emailTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(with: self) { owner, _ in
                owner.viewModel.checkEmailRexValidation.accept(true)
            }
            .disposed(by: disposeBag)
        
        mainView.passwordTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .subscribe(with: self) { owner, _ in
                owner.viewModel.checkPasswordValidation.accept(true)
            }
            .disposed(by: disposeBag)
        
        
        mainView.nicknameTextField.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                if new.count <= 20 {
                    return new
                } else {
                    return previous
                }
            }
            .bind(to: mainView.nicknameTextField.rx.text)
            .disposed(by: disposeBag)
        
        mainView.phoneNumberTextField.rx.text.orEmpty
            .scan("") { (previous, new) -> String in
                if new.count <= 13 {
                    return new
                } else {
                    return previous
                }
            }
            .bind(to: mainView.phoneNumberTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        let input = SignUpViewModel.Input(
            email: mainView.emailTextField.rx.text.orEmpty,
            password: mainView.passwordTextField.rx.text.orEmpty,
            nickname: mainView.nicknameTextField.rx.text.orEmpty,
            phoneNumber: mainView.phoneNumberTextField.rx.text.orEmpty,
            birthday: mainView.datePicker.rx.date
                .map { $0.convertDateToString(format: .compact, localeType: .ko_KR) },
            signUpButtonTap: mainView.signUpButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        output.validation
            .bind(to: mainView.signUpButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.validation
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, value in
                let color = value ? UIColor.systemBlue : UIColor.lightGray
                owner.mainView.signUpButton.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        output.signUpSuccess
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, value in
                if value {
                    owner.showAlertAction1(message: "회원가입에 성공하셨습니다.😃") {
                        owner.dismiss(animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, errorResponse in
                owner.showAlertAction1(message: errorResponse.message)
            }
            .disposed(by: disposeBag)
        

        output.isEmailRexValide
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isValid in
                if !isValid {
                    owner.showAlertAction1(message: "이메일 양식을 확인해주세요")
                    owner.mainView.emailView.layer.borderColor = UIColor.systemRed.cgColor
                }
            }
            .disposed(by: disposeBag)
        
        output.isEmailValide
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isValid in
                if isValid {
                    owner.showAlertAction1(message: "사용 가능한 이메일입니다")
                    owner.mainView.emailView.layer.borderColor = UIColor.lightGray.cgColor
                } else {
                    owner.mainView.emailView.layer.borderColor = UIColor.systemRed.cgColor
                }
            }
            .disposed(by: disposeBag)
        
        output.isPasswordValide
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isValid in
                if isValid {
                    owner.mainView.passwordView.layer.borderColor = UIColor.lightGray.cgColor
                } else {
                    owner.showAlertAction1(message: "8자리 이상 입력해주세요")
                    owner.mainView.passwordView.layer.borderColor = UIColor.systemRed.cgColor
                }
            }
            .disposed(by: disposeBag)
        
    }
}

extension SignUpViewController {
    private func configureNavigationBar() {
        let cancelButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.leftBarButtonItem?.tintColor = UIColor(resource: .tint)
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
}
