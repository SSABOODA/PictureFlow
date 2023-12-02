//
//  CommentCreateView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/2/23.
//

import UIKit
import SnapKit

final class CommentCreateView: UIView {
    
    private var textViewHeightConstraint: Constraint?
    
    let scrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let contentView = {
        let view = UIView()
        return view
    }()
    
    let backView = {
        let view = UIView()
        return view
    }()
    
    let profileImageView = {
        let view = ProfileImageView(frame: .zero)
        return view
    }()
    
    let nicknameLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textColor = UIColor(resource: .text)
        label.text = "sssabooda"
        return label
    }()
    
    let leftDividLineView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let commentTextView = {
        let tv = UITextView()
        tv.text = "답글을 남겨보세요"
        tv.font = .systemFont(ofSize: 17)
        tv.isScrollEnabled = false
        tv.sizeToFit()
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .backgorund)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    private func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backView)
        backView.addSubview(profileImageView)
        backView.addSubview(leftDividLineView)
        backView.addSubview(nicknameLabel)
        backView.addSubview(commentTextView)
    }
    
    private func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.height.greaterThanOrEqualTo(self.snp.height).priority(.low)
            make.width.equalTo(scrollView)
        }
        
        backView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(commentTextView.snp.bottom)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.leading.equalToSuperview().inset(15)
            make.size.equalTo(35)
        }
        
        leftDividLineView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(profileImageView.snp.centerX)
            make.bottom.equalToSuperview().inset(5)
            make.width.equalTo(2)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(15)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
}
