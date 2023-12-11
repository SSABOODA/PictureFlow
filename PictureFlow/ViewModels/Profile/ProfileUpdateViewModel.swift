//
//  ProfileUpdateViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileUpdateViewModel: ViewModelType {
    struct Input {
        let nicknameTextFieldText: ControlProperty<String>
        let phoneNumberTextFieldText: ControlProperty<String>
        let birthDayTextFieldText: ControlProperty<String>
        let updateSuccessBarButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let profileUpdateResponseObservable: PublishSubject<UserProfileUpdateResponse>
    }
    
    var disposeBag = DisposeBag()
    
    var profile: UserProfileRetrieveResponse? = nil
    var profileUpdateRequestObservable = PublishSubject<UserProfileUpdateRequest>()
    var profileUpdateResponseObservable = PublishSubject<UserProfileUpdateResponse>()
    var profileImage = BehaviorSubject<UIImage>(value: UIImage())
    
    func transform(input: Input) -> Output {
        
        Observable.combineLatest(
            input.nicknameTextFieldText,
            input.phoneNumberTextFieldText,
            input.birthDayTextFieldText,
            self.profileImage

        )
        .subscribe(with: self) { owner, profile in
            print("⭐️ profile: \(profile)")
            let profile = UserProfileUpdateRequest(
                nick: profile.0,
                phoneNum: profile.1,
                birthDay: profile.2,
                profile: profile.3
            )
            owner.profileUpdateRequestObservable.onNext(profile)
        }
        .disposed(by: disposeBag)
        
        input.updateSuccessBarButtonTap
            .withLatestFrom(profileUpdateRequestObservable)
            .flatMap {
                Network.shared.requestFormDataConvertible(
                    type: UserProfileUpdateResponse.self,
                    router: .userProfileUpdate(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        model: $0)
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    print("🔥 profile update data", data)
                    owner.profileUpdateResponseObservable.onNext(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
            
        
        
        return Output(
            profileUpdateResponseObservable: profileUpdateResponseObservable
        )
    }
}
