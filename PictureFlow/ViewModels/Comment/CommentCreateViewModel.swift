//
//  CommentCreateViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/3/23.
//

import Foundation
import RxSwift
import RxCocoa

class CommentCreateViewModel: ViewModelType {
    struct Input {
        let commentCreateButtonTap: ControlEvent<Void>
        let commentCreateContentText: ControlProperty<String>
    }
    
    struct Output {
        let commentCreateSuccess: BehaviorRelay<Bool>
        let commentsObservableInfo: PublishSubject<Comments>
        let userProfileObservable: PublishSubject<UserInfo>
        let errorResponse: PublishSubject<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    
    var initTokenObservable = PublishSubject<String>()
    var userProfileObservable = PublishSubject<UserInfo>()
    var commentCreateSuccess = BehaviorRelay(value: false)
    var commentsObservableInfo = PublishSubject<Comments>()
    var commentCreateError = PublishSubject<String>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    var postId: String = ""
    var postList: PostList? = nil
    
    func fetchProfilData() {
        let token = self.checkAccessToken()
        initTokenObservable.onNext(token)
    }

    func transform(input: Input) -> Output {
        
        initTokenObservable
            .flatMap { token in
                Network.shared.requestObservableConvertible(
                    type: UserProfileRetrieveResponse.self,
                    router: .userProfileRetrieve(accessToken: token)
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    let userInfo = UserInfo(
                        _id: data._id,
                        nick: data.nick,
                        profile: data.profile
                    )
                    owner.userProfileObservable.onNext(userInfo)
                case .failure(let error):
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.commentCreateButtonTap
            .withLatestFrom(input.commentCreateContentText)
            .map {
                CommentCreateRequest(content: $0)
            }
            .flatMap {
                Network.shared.requestObservableConvertible(
                    type: CommentCreateResponse.self, 
                    router: .commentCreate(
                        postId: self.postId,
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        model: $0
                    )
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    let newComment = Comments(
                        _id: data._id,
                        content: data.content,
                        time: data.time,
                        creator: data.creator
                    )
                    owner.commentsObservableInfo.onNext(newComment)
                case .failure(let error):
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            commentCreateSuccess: commentCreateSuccess,
            commentsObservableInfo: commentsObservableInfo,
            userProfileObservable: userProfileObservable,
            errorResponse: errorResponse
        )
    }
    
}
