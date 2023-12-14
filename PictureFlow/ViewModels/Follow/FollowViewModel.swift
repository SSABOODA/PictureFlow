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
        var errorObservable: PublishSubject<CustomErrorResponse>
    }
    var disposeBag = DisposeBag()
    
    var initTokenObservable = PublishSubject<String>()
    var userProfile: OtherUserProfileRetrieve? = nil
    var userProfileObservableData = PublishSubject<OtherUserProfileRetrieve>()
    var isFollow = BehaviorRelay(value: false)
    var errorObservable = PublishSubject<CustomErrorResponse>()
    
    var postUserId: String = ""
    var follwerCount: Int = 0
    
    func transform(input: Input) -> Output {
        // true: 팔로우, false: 언팔로우
        
        input.followButtonTap
            .withLatestFrom(isFollow)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .scan(self.isFollow.value) { lastState, newState in !lastState }
            .map { isFollow in
                print("map isFollow: \(isFollow)")
                if isFollow == self.isFollow.value {
                    return !isFollow
                }
                return isFollow
            }
            .map { v -> Router in
                let token = KeyChain.read(key: APIConstants.accessToken) ?? ""
                return v ? .follow(accessToken: token, userId: self.postUserId) : .unfollow(accessToken: token, userId: self.postUserId)
            }
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: FollowResponse.self,
                    router: $0
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    print(data)
                    owner.isFollow.accept(data.followingStatus)
                case .failure(let error):
                    print(error)
                    owner.errorObservable.onNext(error)
                }
            }
            .disposed(by: disposeBag)
            
        
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
//                    print("profile data: \(data)")
                    owner.userProfile = data
                    owner.follwerCount = data.followers.count
                    owner.userProfileObservableData.onNext(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            initTokenObservable: initTokenObservable,
            userProfileObservableData: userProfileObservableData,
            isFollow: isFollow,
            errorObservable: errorObservable
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
