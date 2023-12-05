//
//  PostListViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import Foundation
import RxSwift
import RxCocoa

final class PostListViewModel: ViewModelType {
    struct Input {
    }
    
    struct Output {
        let postListItem: PublishSubject<[PostList]>
        let errorResponse: PublishSubject<CustomErrorResponse>
        let refreshLoading: PublishRelay<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    var nextCursor = ""
    var postListDataSource = [PostList]()
    let postListItem = PublishSubject<[PostList]>()
    
    let tokenObservable = BehaviorSubject<String>(value: "")
    let errorResponse = PublishSubject<CustomErrorResponse>()
    let refreshLoading = PublishRelay<Bool>()
    
    func transform(input: Input) -> Output {
        
        self.updateDateSource()
        
        tokenObservable
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: PostListResponse.self,
                    router: .postList(
                        accessToken: $0,
                        next: self.nextCursor,
                        limit: "10",
                        product_id: "picture_flow"
                    )
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    owner.nextCursor = data.nextCursor
                    owner.postListDataSource = data.data
                    owner.postListItem.onNext(owner.postListDataSource)
                case .failure(let error):
                    print("error.statusCode: \(error.statusCode)")
//                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            postListItem: postListItem,
            errorResponse: errorResponse,
            refreshLoading: refreshLoading
        )
    }
    
    func updateDateSource() {
        self.postListDataSource.removeAll()
        self.nextCursor = "0"
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("🔑 토큰 확인: \(token)")
            tokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }
    
    func prefetchData(next: String) {
        guard let token = KeyChain.read(key: APIConstants.accessToken) else { return }
        Network.shared.requestConvertible(
            type: PostListResponse.self,
            router: .postList(
                accessToken: token,
                next: next,
                limit: "10",
                product_id: "picture_flow"
            )
        ) { result in
            switch result {
            case .success(let data):
                self.nextCursor = data.nextCursor
                self.postListDataSource.append(contentsOf: data.data)
                self.postListItem.onNext(self.postListDataSource)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
