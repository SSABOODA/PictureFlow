//
//  ProfileViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/11/23.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel: ViewModelType {
    struct Input {
        
    }
    
    struct Output {
        let myProfileData: PublishSubject<UserProfileRetrieveResponse>
    }
    
    var disposeBag = DisposeBag()
    
    var initTokenObservable = PublishSubject<String>()
    
    var userProfile: UserProfileRetrieveResponse? = nil
    var userProfileObservableData = PublishSubject<UserProfileRetrieveResponse>()
    
    func transform(input: Input) -> Output {
        
        initTokenObservable
            .flatMap { token in
                Network.shared.requestObservableConvertible(
                    type: UserProfileRetrieveResponse.self,
                    router: .userProfileRetrieve(accessToken: token)
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    owner.userProfile = data
                    owner.userProfileObservableData.onNext(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            myProfileData: userProfileObservableData
        )
    }
    
    func fetchProfileData() {
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("🔑 토큰 확인: \(token)")
            initTokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }

            
    }
    
}