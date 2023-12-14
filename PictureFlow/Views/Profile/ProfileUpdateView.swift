//
//  ProfileUpdateView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit

final class ProfileUpdateView: UIView {
    
    let profileImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "empty-user")
        view.tintColor = UIColor(resource: .tint)
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    
    let nicknameLabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = UIColor(resource: .text)
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    let nicknameTextField = {
        let tf = UITextField()
        tf.placeholder = "닉네임을 입력해주세요"
        tf.textColor = UIColor(resource: .text)
        tf.font = .boldSystemFont(ofSize: 25)
        return tf
    }()
    
    let phoneNumberLabel = {
        let label = UILabel()
        label.text = "전화번호"
        label.textColor = UIColor(resource: .text)
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    let phoneNumberTextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.placeholder = "전화번호을 입력해주세요"
        tf.textColor = UIColor(resource: .text)
        tf.font = .boldSystemFont(ofSize: 25)
        return tf
    }()
    
    let datePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()
    
    let birthdayLabel = {
        let label = UILabel()
        label.text = "생년월일"
        label.textColor = UIColor(resource: .text)
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    lazy var birthdayTextField = {
        let tf = UITextField()
        tf.text = "1992.08.28"
        tf.placeholder = "생년월일을 입력해주세요"
        tf.textColor = UIColor(resource: .text)
        tf.font = .boldSystemFont(ofSize: 25)
        tf.inputView = self.datePicker
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layoutIfNeeded()
    }
    
    private func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(nicknameTextField)
        addSubview(phoneNumberLabel)
        addSubview(phoneNumberTextField)
        addSubview(birthdayLabel)
        addSubview(birthdayTextField)
    }
    
    private func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide).offset(30)
            make.size.equalTo(100)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(20)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.height.equalTo(35)
        }
        
        phoneNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(15)
            make.leading.equalTo(nicknameLabel.snp.leading)
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberLabel.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.height.equalTo(35)
        }
        
        birthdayLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(15)
            make.leading.equalTo(nicknameLabel.snp.leading)
        }
        
        birthdayTextField.snp.makeConstraints { make in
            make.top.equalTo(birthdayLabel.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.height.equalTo(35)
        }
    }
}
