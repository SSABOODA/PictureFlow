//
//  SearchViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
    struct Input {
        let searchBarSearchButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
    }
    
    
    struct Output {
        let hashTagPostListObservable: PublishSubject<[PostList]>
        let errorResponse: PublishSubject<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    
    var nextCursor = ""
    var hashTagWord = PublishSubject<String>()
    var hashTagPostList = [PostList]()
    var hashTagPostListObservable = PublishSubject<[PostList]>()
    var tokenObservable = PublishSubject<String>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    
    func transform(input: Input) -> Output {
        input.searchBarSearchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText, resultSelector: { _, query in
                return query
            })
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
        self.hashTagPostList.removeAll()
        self.nextCursor = ""
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("토큰 확인: \(token)")
            tokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }
    
    func prefetchData(next: String, hashTag: String) {
        guard let token = KeyChain.read(key: APIConstants.accessToken) else { return }
        Network.shared.requestConvertible(
            type: HashTagPostResponse.self,
            router: .hashTag(
                accessToken: token,
                next: next,
                limit: "10",
                product_id: "picture_flow",
                hashTag: hashTag
            )
        ) { result in
            switch result {
            case .success(let data):
                self.nextCursor = data.nextCursor
                self.hashTagPostList.append(contentsOf: data.data)
                self.hashTagPostListObservable.onNext(self.hashTagPostList)
            case .failure(let error):
                self.errorResponse.onNext(error)
            }
        }
    }
}
