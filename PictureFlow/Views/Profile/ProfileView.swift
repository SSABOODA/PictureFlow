//
//  ProfileView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit

final class ProfileView: UIView {
    let profileInfoView = {
        let view = UIView()
        return view
    }()
    
    let nickNameLabel = {
        let label = UILabel()
        label.text = "ssabooda"
        label.font = .boldSystemFont(ofSize: 30)
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let profileImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "add-user")
        view.tintColor = UIColor(resource: .tint)
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let followerUserProfileImageView1 = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person")
        view.tintColor = UIColor(resource: .tint)
        view.contentMode = .scaleToFill
        return view
    }()
    
    let followerUserProfileImageView2 = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person")
        view.tintColor = UIColor(resource: .tint)
        view.contentMode = .scaleToFill
        return view
    }()
    
    let followerUserProfileImageView3 = {
        let view = UIImageView()
        view.image = UIImage(systemName: "person")
        view.tintColor = UIColor(resource: .tint)
        view.contentMode = .scaleToFill
        return view
    }()

    let followerLabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "팔로워 9명"
        return label
    }()
    
    let bottomView = {
        let view = UIView()
        return view
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .bottomSheet)
        configureHierarchy()
        configureLayout()
        
        // 코난
        let urlString = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQU1vlLWxAULVL6qo3QVjH9-c5KxHWJgk7U3eZWReHeig&s"
        if let imageURL = URL(string: urlString) {
            followerUserProfileImageView2.kf.setImage(with: imageURL)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let profileImageViewList = [
            followerUserProfileImageView1,
            followerUserProfileImageView2,
            followerUserProfileImageView3,
            profileImageView
        ]
        
        profileImageViewList.forEach { imageView in
            imageView.layoutIfNeeded()
            imageView.layer.cornerRadius = imageView.frame.width / 2
            imageView.clipsToBounds = true
        }
    }
    
    private func configureHierarchy() {
        addSubview(profileInfoView)
        profileInfoView.addSubview(nickNameLabel)
        profileInfoView.addSubview(profileImageView)
        profileInfoView.addSubview(followerUserProfileImageView1)
        profileInfoView.addSubview(followerUserProfileImageView2)
        profileInfoView.addSubview(followerUserProfileImageView3)
        profileInfoView.addSubview(followerLabel)
        addSubview(bottomView)
    }
    
    private func configureLayout() {
        profileInfoView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalToSuperview().multipliedBy(0.15)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(profileImageView.snp.leading).offset(-15)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(80)
        }

        followerUserProfileImageView1.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.leading.equalTo(nickNameLabel.snp.leading)
            make.size.equalTo(20)
        }
        
        followerUserProfileImageView2.snp.makeConstraints { make in
            make.top.equalTo(followerUserProfileImageView1.snp.top)
            make.size.equalTo(20)
            make.leading.equalTo(followerUserProfileImageView1.snp.leading).offset(10)
        }
        
        followerUserProfileImageView3.snp.makeConstraints { make in
            make.top.equalTo(followerUserProfileImageView1.snp.top)
            make.size.equalTo(20)
            make.leading.equalTo(followerUserProfileImageView2.snp.leading).offset(10)
        }
        
        followerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(followerUserProfileImageView3.snp.centerY)
            make.leading.equalTo(followerUserProfileImageView3.snp.trailing).offset(10)
        }
        
    }
    
}
