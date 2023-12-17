//
//  ProfileChileMyPostListViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/12/23.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProfileChildMyPostListViewModelType: ViewModelType {
    var nextCursor: String { get }
    var initTokenObservable: PublishSubject<String> { get }
    var postList: [PostList] { get }
    var myPostListObservable: PublishSubject<[PostList]> { get }
    var errorResponse: PublishSubject<CustomErrorResponse> { get }
    var refreshLoading: PublishRelay<Bool> { get }
    var activityLoaing: BehaviorRelay<Bool> { get }
    
    func fetchProfileMyPostListData()
    func prefetchData(next: String)
}

final class ProfileChildMyPostListViewModel: ProfileChildMyPostListViewModelType {
    struct Input {}
    
    struct Output {
        let myPostListObservable: PublishSubject<[PostList]>
        let errorResponse: PublishSubject<CustomErrorResponse>
        let refreshLoading: PublishRelay<Bool>
        let activityLoaing: BehaviorRelay<Bool>
    }
    
    var nextCursor = ""
    var disposeBag = DisposeBag()
    var initTokenObservable = PublishSubject<String>()
    var postList = [PostList]()
    var myPostListObservable = PublishSubject<[PostList]>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    let refreshLoading = PublishRelay<Bool>()
    let activityLoaing = BehaviorRelay(value: true)
    
    func transform(input: Input) -> Output {
        initTokenObservable
            .flatMap { token in
                Network.shared.requestObservableConvertible(
                    type: UserProfileMyPostListResponse.self,
                    router: .userProfileMyPostList(
                        accessToken: token,
                        userId: UserDefaultsManager.userID,
                        next: "",
                        limit: "10",
                        product_id: ""
                    )
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    owner.activityLoaing.accept(false)
                    owner.postList = data.data
                    owner.myPostListObservable.onNext(owner.postList)
                case .failure(let error):
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            myPostListObservable: myPostListObservable,
            errorResponse: errorResponse,
            refreshLoading: refreshLoading,
            activityLoaing: activityLoaing
        )
    }
    
    func fetchProfileMyPostListData() {
        self.postList.removeAll()
        self.nextCursor = ""
        let token = self.checkAccessToken()
        initTokenObservable.onNext(token)
    }
    
    func prefetchData(next: String) {
        guard let token = KeyChain.read(key: APIConstants.accessToken) else { return }
        Network.shared.requestConvertible(
            type: UserProfileMyPostListResponse.self,
            router: .userProfileMyPostList(
                accessToken: token,
                userId: UserDefaultsManager.userID,
                next: next,
                limit: "10",
                product_id: "picture_flow"
            )
        ) { result in
            switch result {
            case .success(let data):
                self.nextCursor = data.nextCursor
                self.postList.append(contentsOf: data.data)
                self.myPostListObservable.onNext(self.postList)
            case .failure(let error):
                self.errorResponse.onNext(error)
            }
        }
    }
}
