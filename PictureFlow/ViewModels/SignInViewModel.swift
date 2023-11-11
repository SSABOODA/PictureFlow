//
//  SignInViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation
import RxSwift
import RxCocoa

final class SignInViewModel: ViewModelType {
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
    }
    
    struct Output {
        let validation: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        let validation = Observable
            .combineLatest(input.email, input.password) { emailText, passwordText in
                print(emailText, emailText.validateEmail())
                print(passwordText, passwordText.validatePassword())
                return emailText.validateEmail() && passwordText.validatePassword()
            }
        return Output(validation: validation)
    }
    
}
