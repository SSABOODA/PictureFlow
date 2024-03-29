//
//  CommentTableCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/22/23.
//

import UIKit
import RxSwift

final class CommentCollectionViewCell: UICollectionViewCell {
    let profileImageView = {
        let view = ProfileImageView(frame: .zero)
        return view
    }()
    
    let nicknameLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textColor = UIColor(resource: .text)
        label.text = "Unknown"
        return label
    }()
    
    let commentContentLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let commentCreatedTimeLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor(resource: .text)
        return label
    }()
    
    let moreInfoButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(resource: .text)
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .background)
        layer.addBorder(
            [.top, .bottom],
            color: UIColor.lightGray.withAlphaComponent(0.3),
            width: 1
        )
        
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(commentContentLabel)
        contentView.addSubview(commentCreatedTimeLabel)
        contentView.addSubview(moreInfoButton)
    }
    
    private func configureLayout() {
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalTo(nicknameLabel.snp.leading).offset(-10)
            make.size.equalTo(30)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        commentContentLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalTo(commentCreatedTimeLabel.snp.trailing)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        commentCreatedTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.trailing.equalTo(moreInfoButton.snp.leading).offset(-10)
        }
        
        moreInfoButton.snp.makeConstraints { make in
            make.centerY.equalTo(commentCreatedTimeLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-15)
            make.size.equalTo(25)
        }
    }
}
