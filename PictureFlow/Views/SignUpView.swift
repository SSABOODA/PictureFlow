//
//  SignUpView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit
import SnapKit

final class SignUpView: UIView {
    
    let signUpTitleLabel = {
        let label = UILabel()
        label.text = "회원가입"
        label.font = .boldSystemFont(ofSize: 35)
        return label
    }()
    
    let emailView = {
        let view = LoginInputView()
        return view
    }()
    
    let emailTextField = {
        let tf = LoginTextField(placeholderText: "이메일 주소")
        return tf
    }()
    
    let passwordView = {
        let view = LoginInputView()
        return view
    }()
    
    let passwordTextField = {
        let tf = LoginTextField(placeholderText: "비밀번호")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let nicknameView = {
        let view = LoginInputView()
        return view
    }()
    
    let nicknameTextField = {
        let tf = LoginTextField(placeholderText: "닉네임")
        return tf
    }()
    
    let phoneNumberView = {
        let view = LoginInputView()
        return view
    }()
    
    let phoneNumberTextField = {
        let tf = LoginTextField(placeholderText: "전화번호")
        return tf
    }()
    
    let birthdayView = {
        let view = LoginInputView()
        return view
    }()
    
    let birthdayTextField = {
        let tf = LoginTextField(placeholderText: "생년월일")
        return tf
    }()
    
    let signUpButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("회원가입", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        configureHierarchy()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        addSubview(signUpTitleLabel)
        addSubview(emailView)
        emailView.addSubview(emailTextField)
        addSubview(passwordView)
        passwordView.addSubview(passwordTextField)
        addSubview(nicknameView)
        nicknameView.addSubview(nicknameTextField)
        addSubview(phoneNumberView)
        phoneNumberView.addSubview(phoneNumberTextField)
        addSubview(birthdayView)
        birthdayView.addSubview(birthdayTextField)
        addSubview(signUpButton)
        
        signUpTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-300)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.07)
        }
        
        emailView.snp.makeConstraints { make in
            make.top.equalTo(signUpTitleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(emailView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        nicknameView.snp.makeConstraints { make in
            make.top.equalTo(passwordView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        phoneNumberView.snp.makeConstraints { make in
            make.top.equalTo(nicknameView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        birthdayView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        birthdayTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(birthdayView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
    }
}
