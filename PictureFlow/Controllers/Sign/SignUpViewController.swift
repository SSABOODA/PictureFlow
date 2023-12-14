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
        configureDatePicker()
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
                print("signUpSuccess next VC", value)
                if value {
                    owner.showAlertAction1(message: "회원가입에 성공하셨습니다.😃") {
                        print("회원가입 성공")
                        owner.dismiss(animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        output.errorResponse
            .subscribe(with: self) { owner, errorResponse in
                print("errorResponse: \(errorResponse)")
                owner.showAlertAction1(message: errorResponse.message)
            }
            .disposed(by: disposeBag)
    }
}
