//
//  SearchViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import Foundation
import RxSwift

final class SearchViewModel: ViewModelType {
    struct Input {}
    
    struct Output {
        let hashTagPostListObservable: PublishSubject<[PostList]>
        let errorResponse: PublishSubject<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    
    var hashTagWord = PublishSubject<String>()
    var hashTagPostList = [PostList]()
    var hashTagPostListObservable = PublishSubject<[PostList]>()
    var tokenObservable = PublishSubject<String>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    
    func transform(input: Input) -> Output {
        
        hashTagWord
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: HashTagPostResponse.self,
                    router: .hashTag(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        next: "",
                        limit: "",
                        product_id: "picture_flow",
                        hashTag: $0
                    )
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    print(data)
                    owner.hashTagPostList = data.data
                    owner.hashTagPostListObservable.onNext(owner.hashTagPostList)
                case .failure(let error):
                    print(error)
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            hashTagPostListObservable: hashTagPostListObservable,
            errorResponse: errorResponse
        )
    }
    
    func updateDateSource() {
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("토큰 확인: \(token)")
            tokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }
}
