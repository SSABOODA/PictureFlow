//
//  SignInViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class SignInViewModel: ViewModelType {
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let validation: Observable<Bool>
        let loginSuccess: BehaviorRelay<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let loginSuccess = BehaviorRelay(value: false)

        let validation = Observable
            .combineLatest(input.email, input.password) { emailText, passwordText in
                return emailText.validateEmail() && passwordText.validatePassword()
            }

        let loginText = Observable.zip(input.email, input.password).map { $0 }
        
        input.loginButtonTap
            .withLatestFrom(loginText, resultSelector: { _, text in
                return text
            })
            .subscribe(with: self) { owner, loginText in
                print("tap", loginText)
                let model = LoginRequest(email: loginText.0, password: loginText.1)
                owner.loginRequest(model: model) { response in
                    switch response {
                    case .success(let success):
                        print(success.token)
                        print(success.refreshToken)
                        loginSuccess.accept(true)
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
            .disposed(by: disposeBag)
            
        return Output(
            validation: validation,
            loginSuccess: loginSuccess
        )
    }
}

// fetch API
extension SignInViewModel {
    private func loginRequest(
        model: LoginRequest,
        completion: @escaping (Result<LoginResponse, NetworkError>) -> Void
    ) {
        Network.shared.requestConvertible(
            type: LoginResponse.self,
            router: .login(model: model)
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
