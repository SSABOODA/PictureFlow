//
//  PostUpdateViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/8/23.
//

import UIKit
import RxSwift
import RxCocoa

final class PostUpdateViewModel: NewPostWriteViewModel {
    
    struct Input {
        let rightBarPostUpdateButtonTap: ControlEvent<Void>
        let postUpdateContentText: ControlProperty<String>
        let image: BehaviorSubject<[UIImage]>
    }

    var post: PostList?
    
    var postUpdateRequestModel = PostWriteRequest(
        title: "",
        content: "",
        file: [UIImage](),
        content1: "",
        content2: ""
    )
    
    var postUpdateResponse = PublishSubject<PostUpdateResponse>()
    
    func transform(input: Input) -> Output {
        
        Observable.combineLatest(
            input.postUpdateContentText,
            input.image
        )
        .subscribe(with: self) { owner, postUpdateData in
            print("postUpdateData: \(postUpdateData)" )
            let model = PostWriteRequest(
                title: "",
                content: postUpdateData.0,
                file: postUpdateData.1,
                content1: "",
                content2: ""
            )
            owner.postWriteRequestObservable.onNext(model)
        }
        .disposed(by: disposeBag)
        
        input.postUpdateContentText
            .subscribe(with: self) { owner, text in
                owner.postUpdateRequestModel.content = text
            }
            .disposed(by: disposeBag)
        
        input.rightBarPostUpdateButtonTap
            .withLatestFrom(postWriteRequestObservable)
            .flatMap {
                Network.shared.requestFormDataConvertible(
                    type: PostUpdateResponse.self,
                    router: .postUpdate(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        postId: self.post?._id ?? "",
                        model: $0
                    )
                )
            }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("update data=======", data)
                    owner.successPostCreate.accept(true)
                    owner.postUpdateResponse.onNext(data)
                case .failure(let error):
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            photoImageObservableList: photoImageObservableList,
            postWriteRequestObservable: postWriteRequestObservable,
            successPostCreate: successPostCreate, 
            userProfileObservable: userProfileObservable, 
            errorResponse: errorResponse
        )
    }
   
}
