//
//  LikeViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import Foundation
import RxSwift

final class LikeViewModel: ViewModelType {
    struct Input {}
    struct Output {
        let likedPostListObservable: PublishSubject<[PostList]>
        let errorResponse: PublishSubject<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    var initTokenObservable = PublishSubject<String>()
    
    var likedPostList = [PostList]()
    var likedPostListObservable = PublishSubject<[PostList]>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    func transform(input: Input) -> Output {
        initTokenObservable
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: LikedPostListResponse.self,
                    router: .likedPost(accessToken: $0)
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    owner.likedPostList = data.data
                    owner.likedPostListObservable.onNext(owner.likedPostList)
                case .failure(let error):
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        return Output(
            likedPostListObservable: likedPostListObservable,
            errorResponse: errorResponse
        )
    }
    
    func fetchUpdateDataSource() {
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("🔑 토큰 확인: \(token)")
            initTokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }
    
}
