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
        var birthday: ControlProperty<String>
        var signUpButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let validation: Observable<Bool>
        var signUpSuccess: BehaviorRelay<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let signUpSuccess = BehaviorRelay(value: false)
        
        let validation = Observable
            .combineLatest(input.email, input.password, input.nickname) { email, password, nickname in
                return email.validateEmail() && password.validatePassword() && nickname.count > 0
            }
        
        let signUpText = Observable.zip(
            input.email,
            input.password,
            input.nickname,
            input.phoneNumber,
            input.birthday
        ).map { $0 }
        
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
                owner.signUpRequest(model: model) { response in
                    switch response {
                    case .success(let success):
                        print(success._id)
                        print(success.email)
                        print(success.nick)
                        signUpSuccess.accept(true)
                    case .failure(let failure):
                        print(failure.localizedDescription)
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
            router: .join
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
