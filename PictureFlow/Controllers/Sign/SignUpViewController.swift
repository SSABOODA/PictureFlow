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
        bind()
        mainView.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
    }
    
    @objc func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        self.diaryDate = datePicker.date
        self.mainView.birthdayTextField.text = datePicker.date.convertDateToString(format: .compact)
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
            birthday: mainView.datePicker.rx.date
                .map { $0.convertDateToString(format: .compact) },
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
            .asDriver()
            .drive(with: self) { owner, value in
                print("signUpSuccess next VC", value)
                if value {
                    owner.showAlertAction1(title: "회원가입에 성공하셨습니다.😃")
                    owner.showAlertAction1(title: "회원가입에 성공하셨습니다.😃") {
                        let vc = HomeViewController()
                        owner.transition(viewController: vc, style: .push)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}
