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
    
    let postListItem = PublishSubject<[PostList]>()
    let errorResponse = PublishSubject<CustomErrorResponse>()
    let tokenObservable = BehaviorSubject<String>(value: "")
    let refreshLoading = PublishRelay<Bool>()
    
    func transform(input: Input) -> Output {
        
        self.updateDateSource()
        
        tokenObservable
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: PostListResponse.self,
                    router: .postList(
                        accessToken: $0,
                        limit: "10",
                        product_id: "picture_flow"
                    )
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
//                    print(data)
                    owner.postListItem.onNext(data.data)
                case .failure(let error):
                    print("error.statusCode: \(error.asAFError?.responseCode)")
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
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("토큰 확인: \(token)")
            tokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }
}
