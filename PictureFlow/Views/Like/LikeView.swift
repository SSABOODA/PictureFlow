//
//  LikeView.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit

final class LikeView: PostListView {
    
    let emptyLabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "좋아요한 게시글이 없어요..."
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureHierarchy() {
        addSubview(emptyLabel)
    }
    
    private func configureLayout() {
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}
