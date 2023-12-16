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
    
    var nextCursor = ""
    var initTokenObservable = PublishSubject<String>()
    var likedPostList = [PostList]()
    var likedPostListObservable = PublishSubject<[PostList]>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    
    func transform(input: Input) -> Output {
        initTokenObservable
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: LikedPostListResponse.self,
                    router: .likedPost(
                        accessToken: $0,
                        next: "",
                        limit: ""
                    )
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
        self.likedPostList.removeAll()
        self.nextCursor = ""
        let token = self.checkAccessToken()
        initTokenObservable.onNext(token)
    }
    
    func prefetchData(next: String) {
        guard let token = KeyChain.read(key: APIConstants.accessToken) else { return }
        Network.shared.requestConvertible(
            type: LikedPostListResponse.self,
            router: .likedPost(
                accessToken: token,
                next: next,
                limit: "10"
            )
        ) { result in
            switch result {
            case .success(let data):
                self.nextCursor = data.nextCursor
                self.likedPostList.append(contentsOf: data.data)
                self.likedPostListObservable.onNext(self.likedPostList)
            case .failure(let error):
                self.errorResponse.onNext(error)
            }
        }
    }
    
}
