//
//  ProfileChileMyPostListView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/12/23.
//

import UIKit


final class ProfileChileMyPostListView: PostListView {
    let firstStartButton = {
        let button = UIButton()
        button.setTitle("  첫 이야기 시작...  ", for: .normal)
        button.backgroundColor = UIColor(resource: .background)
        button.setTitleColor(UIColor(resource: .text), for: .normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
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
    
    private func configureHierarchy() {
        tableView.addSubview(firstStartButton)
    }
    
    private func configureLayout() {
        firstStartButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(35)
        }
    }
    
    
}
