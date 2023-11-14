//
//  SignUpViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/12/23.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModelType {
    
    struct Input {
        var email: ControlProperty<String>
        var password: ControlProperty<String>
        var nickname: ControlProperty<String>
        var phoneNumber: ControlProperty<String>
        var birthday: Observable<String>
        var signUpButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let validation: Observable<Bool>
        var signUpSuccess: BehaviorRelay<Bool>
        var errorMessage: PublishSubject<String>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let signUpSuccess = BehaviorRelay(value: false)
        let model = SignUpReqeust(
            email: "",
            password: "",
            nickname: "",
            phoneNumber: "",
            birthday: "")
        let signUpModelObservable = BehaviorRelay<SignUpReqeust>(value: model)
        let errorMessage = PublishSubject<String>()
        
        let validation = Observable
            .combineLatest(
                input.email,
                input.password,
                input.nickname,
                input.phoneNumber,
                input.birthday
            ) { email, password, nickname, phoneNumber, birthday in
                let result =
                email.validateEmail() &&
                password.validatePassword() &&
                nickname.count > 0 &&
                phoneNumber.validatePhoneNumber()
                return result
            }
        
        Observable.combineLatest(
            input.email,
            input.password,
            input.nickname,
            input.phoneNumber,
            input.birthday
        )
        .subscribe(with: self) { owner, text in
            let model = SignUpReqeust(
                email: text.0,
                password: text.1,
                nickname: text.2,
                phoneNumber: text.3,
                birthday: text.4
            )
            signUpModelObservable.accept(model)
        }
        .disposed(by: disposeBag)

        input.signUpButtonTap
            .take(1)
            .withLatestFrom(signUpModelObservable)
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: SignUpResponse.self,
                    router: .join(model: $0)
                )
            }
            .catch { error in
                print("error: \(error)")
                if let error = error as? NetworkError {
                    let message = error.errorDescription
                    errorMessage.onNext(message)
                }
                
                return Observable.empty()
            }
            .subscribe(with: self) { owner, response in
                print(response._id)
                print(response.email)
                print(response.nick)
                signUpSuccess.accept(true)
            }
            .disposed(by: disposeBag)

        return Output(
            validation: validation,
            signUpSuccess: signUpSuccess,
            errorMessage: errorMessage
        )
    }
    
}
