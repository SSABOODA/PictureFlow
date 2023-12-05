//
//  CommentCreateViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/3/23.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentCreateViewModel: ViewModelType {
    struct Input {
        let commentCreateButtonTap: ControlEvent<Void>
        let commentCreateContentText: ControlProperty<String>
    }
    
    struct Output {
        let commentCreateSuccess: BehaviorRelay<Bool>
        let commentsObservableInfo: PublishSubject<Comments>
    }
    
    var disposeBag = DisposeBag()
    
    var postId: String = ""
    
    var commentCreateSuccess = BehaviorRelay(value: false)
    var commentsObservableInfo = PublishSubject<Comments>()
    var commentCreateError = PublishSubject<String>()

    func transform(input: Input) -> Output {
        
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
                    print(data)
                    
                    let newComment = Comments(
                        _id: data._id,
                        content: data.content,
                        time: data.time,
                        creator: data.creator
                    )
                    
                    owner.commentsObservableInfo.onNext(newComment)
//                    owner.commentCreateSuccess.accept(true)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            commentCreateSuccess: commentCreateSuccess,
            commentsObservableInfo: commentsObservableInfo
        )
    }
    
}
