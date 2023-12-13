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
        let isFollow: BehaviorRelay<Bool>
    }
    var disposeBag = DisposeBag()
    
    var initTokenObservable = PublishSubject<String>()
    var userProfile: OtherUserProfileRetrieve? = nil
    var userProfileObservableData = PublishSubject<OtherUserProfileRetrieve>()
    
    var isFollow = BehaviorRelay(value: false)
    
    var postUserId: String = ""
    
    func transform(input: Input) -> Output {
        input.followButtonTap
            .withLatestFrom(isFollow)
            .scan(false) { lastState, newState in !lastState }
            .map { isFollow in
                // true: 팔로우, false: 언팔로우
                print("isFollow: \(isFollow)")
                print("isFollowRelay: \(self.isFollow.value)")
                
                if isFollow == self.isFollow.value {
                    self.isFollow.accept(!isFollow)
                    return !isFollow
                }
                
                self.isFollow.accept(isFollow)
                return isFollow
            }
            .bind(with: self, onNext: { owner, _ in
            })
            .disposed(by: disposeBag)
        
        
//            .map { v -> Router in
//                let token = KeyChain.read(key: APIConstants.accessToken) ?? ""
//                return v ? .follow(accessToken: token, userId: self.postUserId) : .unfollow(accessToken: token, userId: self.postUserId)
//            }
//            .flatMap {
//                Network.shared.requestObservableConvertible(
//                    type: FollowResponse.self,
//                    router: $0
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
            userProfileObservableData: userProfileObservableData,
            isFollow: isFollow
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
