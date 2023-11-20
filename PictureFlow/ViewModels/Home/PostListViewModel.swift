//
//  PostListViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import Foundation
import RxSwift

final class PostListViewModel: ViewModelType {
    struct Input {
    }
    
    struct Output {
        let postListItem: PublishSubject<[PostList]>
        let errorResponse: PublishSubject<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let postListItem = PublishSubject<[PostList]>()
        let errorResponse = PublishSubject<CustomErrorResponse>()
        let tokenObservable = BehaviorSubject<String>(value: "")
        
//        print("토큰 확인: \(KeyChain.read(key: APIConstants.accessToken))")
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            tokenObservable.onNext(token)
        }
        
        tokenObservable
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: PostListResponse.self,
                    router: .postList(
                        accessToken: $0,
                        product_id: "picture_flow"
                    )
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
//                    print(data)
                    postListItem.onNext(data.data)
                case .failure(let error):
                    print("error.statusCode: \(error.statusCode)")
                    errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            postListItem: postListItem,
            errorResponse: errorResponse
        )
    }
}
