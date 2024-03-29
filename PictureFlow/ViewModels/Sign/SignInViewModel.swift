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
        let errorResponse: PublishRelay<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    let loginModel = LoginRequest(email: "", password: "")
    
    
    func transform(input: Input) -> Output {
        let loginSuccess = BehaviorRelay(value: false)
        let errorResponse = PublishRelay<CustomErrorResponse>()
        let loginModelObservable = BehaviorSubject<LoginRequest>(value: loginModel)
        
        let validation = Observable
            .combineLatest(input.email, input.password) { emailText, passwordText in
                return emailText.validateEmail() && passwordText.validatePassword()
            }
        
        Observable.combineLatest(
            input.email,
            input.password
        )
        .subscribe(with: self) { owner, inputText in
            let model = LoginRequest(
                email: inputText.0,
                password: inputText.1
            )
            loginModelObservable.onNext(model)
        }
        .disposed(by: disposeBag)
        
        input.loginButtonTap
            .withLatestFrom(loginModelObservable)
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: LoginResponse.self,
                    router: .login(model: $0)
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let success):
                    KeyChain.create(key: APIConstants.accessToken, token: success.token)
                    KeyChain.create(key: APIConstants.refreshToken, token: success.refreshToken)
                    UserDefaultsManager.isLoggedIn = true
                    UserDefaultsManager.userID = success._id
                    loginSuccess.accept(true)
                case .failure(let error):
                    errorResponse.accept(error)
                }
            } onDisposed: { owner in
                print("onDisposed")
            }
            .disposed(by: disposeBag)
        
        return Output(
            validation: validation,
            loginSuccess: loginSuccess,
            errorResponse: errorResponse
        )
    }
}
