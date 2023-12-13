//
//  FollowView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/13/23.
//

import UIKit

final class FollowView: ProfileView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
    }
   
    override func configureLayoutView() {
        profileInfoView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalToSuperview()
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
            make.top.equalTo(nickNameLabel.snp.bottom).offset(10)
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
