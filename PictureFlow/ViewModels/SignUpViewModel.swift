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
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let signUpSuccess = BehaviorRelay(value: false)
        
        let email = BehaviorSubject(value: "")
        let password = BehaviorSubject(value: "")
        let nickname = BehaviorSubject(value: "")
        let phoneNumber = BehaviorSubject(value: "")
        let birthday = BehaviorSubject(value: "")
        
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
        
        let signUpText = Observable.combineLatest(
            input.email,
            input.password,
            input.nickname,
            input.phoneNumber,
            input.birthday
        )
        
        signUpText
            .subscribe(with: self) { owner, text in
                email.onNext(text.0)
                password.onNext(text.1)
                nickname.onNext(text.2)
                phoneNumber.onNext(text.3)
                birthday.onNext(text.4)
            }
            .disposed(by: disposeBag)
        
        input.signUpButtonTap
            .withLatestFrom(signUpText, resultSelector: { _, text in
                return text
            })
            .map {
                return SignUpReqeust(
                    email: $0.0,
                    password: $0.1,
                    nickname: $0.2,
                    phoneNumber: $0.3,
                    birthday: $0.4
                )
            }
            .subscribe(with: self) { owner, model in
                print("ㅎㅎ 눌렀당")
                print("model: \(model)")
                
                owner.signUpRequest(model: model) { response in
                    switch response {
                    case .success(let success):
                        print("_id:", success._id)
                        print("email:", success.email)
                        print("nick:", success.nick)
                        signUpSuccess.accept(true)
                    case .failure(let error):
                        print(error.errorDescription, error)
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        return Output(
            validation: validation,
            signUpSuccess: signUpSuccess
        )
    }
    
}

// fetch API
extension SignUpViewModel {
    private func signUpRequest(
        model: SignUpReqeust,
        completion: @escaping (Result<SignUpResponse, NetworkError>) -> Void
    ) {
        Network.shared.requestConvertible(
            type: SignUpResponse.self,
            router: .join(model: model)
        ) { response in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
