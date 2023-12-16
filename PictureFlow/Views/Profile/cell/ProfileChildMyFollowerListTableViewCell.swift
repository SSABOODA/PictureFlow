//
//  ProfileChildMyFollowerListTableViewCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/16/23.
//

import UIKit
import RxSwift

final class ProfileChildMyFollowerListTableViewCell: UITableViewCell {
    
    let profileImageView = {
        let view = ProfileImageView(frame: .zero)
        return view
    }()
    
    let nicknameLabel = {
        let label = UILabel()
        label.text = "unknown"
        label.textColor = UIColor(resource: .text)
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    let followButton = {
        let button = UIButton()
        button.setTitle("팔로우", for: .normal)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.backgroundColor = UIColor(resource: .background)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(resource: .background)
        selectionStyle = .none
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(followButton)
    }
    
    private func configureLayout() {
        
        profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.size.equalTo(40)
            make.verticalEdges.equalToSuperview().inset(15)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.leading.equalTo(profileImageView.snp.trailing).offset(15)
            make.trailing.equalTo(followButton.snp.leading).offset(-10)
        }
        
        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    func configureCell(element: UserInfo, isFollowingStatus: Bool) {
        element.profile?.loadProfileImageByKingfisher(imageView: profileImageView)
        nicknameLabel.text = element.nick
        
        if !isFollowingStatus {
            followButton.setTitle("팔로우", for: .normal)
            followButton.setImage(nil, for: .normal)
            followButton.setTitleColor(UIColor(resource: .text), for: .normal)
        } else {
            followButton.setTitle("팔로잉", for: .normal)
            followButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            followButton.setTitleColor(.darkGray, for: .normal)
            followButton.tintColor = .darkGray
        }
    }
}
