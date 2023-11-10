//
//  JoinButton.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit

final class JoinButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
        clipsToBounds = true
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
