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
        var errorResponse: PublishRelay<CustomErrorResponse>
        let isEmailRexValide: PublishRelay<Bool>
        let isEmailValide: PublishRelay<Bool>
        let isPasswordValide: PublishRelay<Bool>
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
    
    let checkEmailRexValidation = PublishRelay<Bool>()
    let isEmailRexValide = PublishRelay<Bool>()
    
    let checkEmailValidation = PublishSubject<Bool>()
    let isEmailValide = PublishRelay<Bool>()
    
    let checkPasswordValidation = PublishRelay<Bool>()
    let isPasswordValide = PublishRelay<Bool>()
    
    let validation = BehaviorSubject<Bool>(value: false)
    
    func transform(input: Input) -> Output {
        let signUpSuccess = BehaviorRelay(value: false)
        let errorResponse = PublishRelay<CustomErrorResponse>()
        
        let signUpModelObservable = BehaviorSubject<SignUpReqeust>(value: model)
        let validationModelObservable = BehaviorSubject<ValidationRequest>(value: validationModel)
        
        let emailValidation = BehaviorRelay(value: false)
        
        checkEmailRexValidation
            .withLatestFrom(input.email)
            .subscribe(with: self) { owner, email in
                if email.validateEmail() {
                    owner.checkEmailValidation.onNext(true)
                } else {
                    owner.isEmailRexValide.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        checkEmailValidation
            .withLatestFrom(input.email)
            .take(while: { emailText in
                return !emailText.isEmpty
            })
            .map {
                return ValidationRequest(email: $0)
            }
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: ValidationResponse.self,
                    router: .validation(model: $0)
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(_):
                    owner.isEmailValide.accept(true)
                case .failure(let error):
                    owner.isEmailValide.accept(false)
                    errorResponse.accept(error)
                }
            }
            .disposed(by: disposeBag)
        
        checkPasswordValidation
            .withLatestFrom(input.password)
            .take(while: { emailText in
                return !emailText.isEmpty
            })
            .subscribe(with: self) { owner, password in
                if password.validatePassword() {
                    owner.isPasswordValide.accept(true)
                } else {
                    owner.isPasswordValide.accept(false)
                }
            }
            .disposed(by: disposeBag)
            
        
        Observable
            .combineLatest(
                self.checkEmailValidation,
                self.checkPasswordValidation,
                input.nickname,
                input.phoneNumber,
                input.birthday
            ) { email, password, nickname, phoneNumber, birthday in
                let result =
                email &&
                password &&
                nickname.count > 0 &&
                phoneNumber.validatePhoneNumber()
                return result
            }
            .subscribe(with: self) { owner, result in
                owner.validation.onNext(result)
            }
            .disposed(by: disposeBag)
        
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
                Network.shared.requestObservableConvertible(
                    type: ValidationResponse.self,
                    router: .validation(model: $0)
                )
            }
            // bind, drive 변경해도 됨
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    emailValidation.accept(true)
                case .failure(let error):
                    _ = APICustomError.CommonError(rawValue: error.statusCode)?.errorDescription
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
                Network.shared.requestObservableConvertible(
                    type: SignUpResponse.self,
                    router: .join(model: $0)
                )
            }
            .debug("signUpButtonTap")
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_):
                    signUpSuccess.accept(true)
                case .failure(let error):
                    print("\(error)")
                }
            } onDisposed: { owner in
                print("onDisposed")
            }
            .disposed(by: disposeBag)

        return Output(
            validation: validation,
            signUpSuccess: signUpSuccess,
            errorResponse: errorResponse,
            isEmailRexValide: isEmailRexValide,
            isEmailValide: isEmailValide,
            isPasswordValide: isPasswordValide
        )
    }
    
}
