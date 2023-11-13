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
        return evaluatePredicate(emailRegEx)
    }
    
    // 패스워드
    func validatePassword() -> Bool {
        let passwordRegEx = "^(?=.*[a-zA-Z0-9]).{8,}$"
        return evaluatePredicate(passwordRegEx)
    }
    
    // 전화번호
    func validatePhoneNumber() -> Bool {
        let phoneNumberRegEx = "^01[0-1, 7][0-9]{7,8}$"
        return evaluatePredicate(phoneNumberRegEx)
    }
    
    private func evaluatePredicate(_ regEx: String) -> Bool {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with: self)
    }
}
