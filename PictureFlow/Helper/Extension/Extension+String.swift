//
//  Extension+String.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation

extension String {
    
    // 이메일 정규식
    func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
    // 패스워드
    func validatePassword() -> Bool {
//        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$"
        let passwordRegEx = "^(?=.*[a-zA-Z0-9]).{8,}$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: self)
    }
}
