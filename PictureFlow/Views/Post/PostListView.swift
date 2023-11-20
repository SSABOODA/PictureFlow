//
//  PostListView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit

final class PostListView: UIView {
    
    let nicknameLabel = {
        let lb = UILabel()
        return lb
    }()
    
    let postTitleLabel = {
        let lb = UILabel()
        return lb
    }()
    
    let postContentLabel = {
        let lb = UILabel()
        return lb
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(resource: .backgorund)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
