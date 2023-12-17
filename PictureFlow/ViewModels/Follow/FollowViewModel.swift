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
    
    var isFollowingStatus: Bool = false
    
    var postUserId: String = ""
    var follwerCount: Int = 0
    
    func transform(input: Input) -> Output {
        // true: 팔로우, false: 언팔로우
        
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
                    owner.follwerCount = data.followers.count
                    owner.userProfileObservableData.onNext(data)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.followButtonTap
            .withLatestFrom(isFollow)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .map { v -> Router in
                let token = KeyChain.read(key: APIConstants.accessToken) ?? ""
                return !v ? .follow(accessToken: token, userId: self.postUserId) : .unfollow(accessToken: token, userId: self.postUserId)
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
                    owner.errorObservable.onNext(error)
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
        let token = self.checkAccessToken()
        initTokenObservable.onNext(token)
    }

}
