//
//  FollowViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/13/23.
//

import Foundation
import RxSwift
import RxCocoa

final class FollowViewModel: ViewModelType {
    struct Input {
        let followButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let initTokenObservable: PublishSubject<String>
        let userProfileObservableData: PublishSubject<OtherUserProfileRetrieve>
    }
    var disposeBag = DisposeBag()
    
    var initTokenObservable = PublishSubject<String>()
    var userProfile: OtherUserProfileRetrieve? = nil
    var userProfileObservableData = PublishSubject<OtherUserProfileRetrieve>()
    
    var postUserId: String = ""
    
    func transform(input: Input) -> Output {
        input.followButtonTap
            .scan(false) { lastState, newState in !lastState }
            .map { isFollow in
                print("isFollow: \(isFollow)")
            }
            .bind(with: self) { owner, _ in
                print(123)
            }
            .disposed(by: disposeBag)
//            .flatMap {
//                Network.shared.requestObservableConvertible(
//                    type: FollowResponse.self,
//                    router: .follow(
//                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
//                        userId: self.postUserId
//                    )
//                )
//            }
//            .subscribe(with: self) { owner, response in
//                switch response {
//                case .success(let data):
//                    print(data)
//                case .failure(let error):
//                    print(error)
//                }
//            }
//            .disposed(by: disposeBag)
        
        
        initTokenObservable
            .flatMap { token in
                Network.shared.requestObservableConvertible(
                    type: OtherUserProfileRetrieve.self,
                    router: .otherUserProfileRetrieve(
                        accessToken: token,
                        userId: self.postUserId
                    )
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
            initTokenObservable: initTokenObservable,
            userProfileObservableData: userProfileObservableData
        )
    }
    
    func fetchProfilData() {
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("🔑 토큰 확인: \(token)")
            initTokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }

}
