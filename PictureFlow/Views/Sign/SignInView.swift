//
//  SignInView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit

final class SignInView: UIView {
    
    let loginTitleLabel = {
        let label = UILabel()
        label.text = "로그인"
        label.font = .boldSystemFont(ofSize: 35)
        return label
    }()
    
    let emailView = {
        let view = LoginInputView()
        return view
    }()
    
    let emailTextField = {
        let tf = LoginTextField(placeholderText: "이메일")
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
    
    let passwordSecureButton = {
        let button = UIButton()
        return button
    }()
    
    let loginButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        return button
    }()
    
    let signUpButton = {
        let button = UIButton()
        button.setTitle("계정이 없으세요? 가입하러 가기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
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
        addSubview(loginTitleLabel)
        addSubview(emailView)
        emailView.addSubview(emailTextField)
        addSubview(passwordView)
        passwordView.addSubview(passwordTextField)
        passwordView.addSubview(passwordSecureButton)
        addSubview(loginButton)
        addSubview(signUpButton)
        
        loginTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.07)
        }
        
        emailView.snp.makeConstraints { make in
            make.top.equalTo(loginTitleLabel.snp.bottom).offset(15)
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
        
        passwordSecureButton.snp.makeConstraints { make in
            make.trailing.equalTo(passwordView.snp.trailing).offset(-20)
            make.width.equalToSuperview().multipliedBy(0.08)
            make.verticalEdges.equalToSuperview().inset(10)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(passwordSecureButton.snp.leading).offset(-10)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        
    }
}
