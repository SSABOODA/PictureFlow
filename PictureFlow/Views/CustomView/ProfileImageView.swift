//
//  ProfileImageView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/25/23.
//

import UIKit

class ProfileImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        image = UIImage(named: "empty-user")
        clipsToBounds = true
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = .white
        tintColor = UIColor(resource: .background)
        contentMode = .scaleAspectFill
        isUserInteractionEnabled = true
    }
}
