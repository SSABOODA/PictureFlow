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

    func transform(input: Input) -> Output {
        Observable.combineLatest(
            input.postUpdateContentText,
            input.image
        )
        .subscribe(with: self) { owner, postUpdateData in
            print("postUpdateData: \(postUpdateData)")
            let model = PostWriteRequest(
                title: "",
                content: postUpdateData.0,
                file: postUpdateData.1,
                content1: "test1",
                content2: "test2"
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
                    router: .postUpdate(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        postId: self.post?._id ?? "",
                        model: $0
                    )
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print(data)
                    owner.successPostCreate.accept(true)
                case .failure(let error):
                    print(error.message)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            photoImageObservableList: photoImageObservableList,
            postWriteRequestObservable: postWriteRequestObservable,
            successPostCreate: successPostCreate
        )
    }
   
}
