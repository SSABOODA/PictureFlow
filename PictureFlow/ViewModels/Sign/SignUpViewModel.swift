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
        var errorResponse: PublishRelay<ErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    let model = SignUpReqeust(
        email: "",
        password: "",
        nickname: "",
        phoneNumber: "",
        birthday: ""
    )
    let validationModel = ValidationRequest(
        email: ""
    )
    
    func transform(input: Input) -> Output {
        let signUpSuccess = BehaviorRelay(value: false)
        let errorSubject = PublishSubject<NetworkError>()
        let errorResponse = PublishRelay<ErrorResponse>()
        
        let signUpModelObservable = BehaviorSubject<SignUpReqeust>(value: model)
        let validationModelObservable = BehaviorSubject<ValidationRequest>(value: validationModel)
        
        let emailValidation = BehaviorRelay(value: false)
        
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
            signUpModelObservable.onNext(model)
            
            let validationModel = ValidationRequest(email: text.0)
            validationModelObservable.onNext(validationModel)
        }
        .disposed(by: disposeBag)
        
        input.signUpButtonTap
            .withLatestFrom(validationModelObservable)
            .flatMap {
                Network.shared.requestObservableConvertible2(
                    type: ValidationResponse.self,
                    router: .validation(model: $0)
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let success):
                    print(success.message)
                    emailValidation.accept(true)
                case .failure(let error):
                    print("\(error)")
                    errorResponse.accept(error)
                }
            } onDisposed: { owner in
                print("onDisposed")
            }
            .disposed(by: disposeBag)
        
        emailValidation
            .filter { $0 == true }
            .withLatestFrom(signUpModelObservable)
            .flatMap {
                Network.shared.requestObservableConvertible2(
                    type: SignUpResponse.self,
                    router: .join(model: $0)
                )
            }
            .debug("signUpButtonTap")
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let succes):
                    print(succes._id)
                    print(succes.email)
                    print(succes.nick)
                    signUpSuccess.accept(true)
                case .failure(let error):
                    print("subscribe \(error)")
                    errorResponse.accept(error)
                }
            } onDisposed: { owner in
                print("onDisposed")
            }
            .disposed(by: disposeBag)

        return Output(
            validation: validation,
            signUpSuccess: signUpSuccess,
            errorResponse: errorResponse
        )
    }
    
}
