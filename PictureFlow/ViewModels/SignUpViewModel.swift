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
        var errorSubject: PublishSubject<NetworkError>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let signUpSuccess = BehaviorRelay(value: false)
        let model = SignUpReqeust(
            email: "",
            password: "",
            nickname: "",
            phoneNumber: "",
            birthday: ""
        )
        let signUpModelObservable = BehaviorSubject<SignUpReqeust>(value: model)
        let errorSubject = PublishSubject<NetworkError>()
        
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
        }
        .disposed(by: disposeBag)

        errorSubject
            .bind(with: self) { owner, error in
                print(error)
            }
            .disposed(by: disposeBag)
        
        input.signUpButtonTap
            .withLatestFrom(signUpModelObservable)
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: SignUpResponse.self,
                    router: .join(model: $0)
                )
            }
            .debug("signUpButtonTap")
            .subscribe(with: self) { owner, result in // drive, bind로 바꿔도 될 듯
                switch result {
                case .success(let succes):
                    print(succes._id)
                    print(succes.email)
                    print(succes.nick)
                    signUpSuccess.accept(true)
                case .failure(let error):
                    print("나오면 억까 \(error)")
                    errorSubject.onNext(error)
                }
            } onDisposed: { owner in
                print("onDisposed")
            }
            .disposed(by: disposeBag)

        return Output(
            validation: validation,
            signUpSuccess: signUpSuccess,
            errorSubject: errorSubject
        )
    }
    
}
