//
//  LoginView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit
import SnapKit

final class JoinView: UIView {
    
    let signUpButton = {
        let button = JoinButton()
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = .systemRed
        return button
    }()
    
    let signInButton = {
        let button = JoinButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        configureHierarchy()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        addSubview(signUpButton)
        addSubview(signInButton)
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-25)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
        
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.06)
        }
    }
    
}
