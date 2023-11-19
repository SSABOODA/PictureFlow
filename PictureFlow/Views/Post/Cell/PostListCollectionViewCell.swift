//
//  PostListCollectionViewCell.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/19/23.
//

import UIKit

final class PostListCollectionViewCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.backgroundColor = .red
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: String) {
        print("itme: \(item)")
        label.text = item
    }   
}
