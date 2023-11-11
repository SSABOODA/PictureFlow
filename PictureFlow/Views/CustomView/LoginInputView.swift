//
//  LoginInputView.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit

final class LoginInputView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
