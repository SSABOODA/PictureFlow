//
//  LoginTextField.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/10/23.
//

import UIKit

final class LoginTextField: UITextField {
    
    init(placeholderText: String) {
        super.init(frame: .zero)
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
        textColor = .black
        clearButtonMode = .whileEditing
        
        autocorrectionType = .no
        autocapitalizationType = .none
        spellCheckingType = .no
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
