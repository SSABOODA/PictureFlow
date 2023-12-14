//
//  ProfileChileMyPostListViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/12/23.
//

import Foundation
import RxSwift

final class ProfileChileMyPostListViewModel: ViewModelType {
    struct Input {}
    
    struct Output {
        let myPostListObservable: PublishSubject<[PostList]>
    }
    
    var disposeBag = DisposeBag()
    var initTokenObservable = PublishSubject<String>()
    
    var postList = [PostList]()
    var myPostListObservable = PublishSubject<[PostList]>()
    
    func transform(input: Input) -> Output {
        initTokenObservable
            .flatMap { token in
                Network.shared.requestObservableConvertible(
                    type: UserProfileMyPostListResponse.self,
                    router: .userProfileMyPostList(
                        accessToken: token,
                        userId: UserDefaultsManager.userID,
                        next: "",
                        limit: "",
                        product_id: ""
                    )
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    owner.postList = data.data
                    owner.myPostListObservable.onNext(owner.postList)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
            
        
        return Output(
            myPostListObservable: myPostListObservable
        )
    }
    
    func fetchProfileMyPostListData() {
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("🔑 토큰 확인: \(token)")
            initTokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }
}
