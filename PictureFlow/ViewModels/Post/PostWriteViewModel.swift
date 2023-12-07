//
//  PostWriteViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/28/23.
//

import UIKit
import RxSwift
import RxCocoa

final class PostWriteViewModel: ViewModelType {
    struct Input {
        let postCreateButtonTap: ControlEvent<Void>
        let postContentText: ControlProperty<String>
    }
    
    struct Output {
        let postWriteRequestObservable: PublishSubject<PostWriteRequest>
        let photoImageObservableList: BehaviorSubject<[UIImage]>
        let successPostCreate: BehaviorRelay<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    var post: PostList?
    
    var postWriteRequestModel = PostWriteRequest(
        title: "",
        content: "",
        file: [UIImage](),
        content1: "",
        content2: ""
    )
    var postWriteRequestObservable = PublishSubject<PostWriteRequest>()
    
    var photoImageList = [UIImage]()
    var photoImageObservableList = BehaviorSubject<[UIImage]>(value: [])
    var successPostCreate = BehaviorRelay(value: false)
    
    func transform(input: Input) -> Output {
        
        input.postContentText
            .subscribe(with: self) { owner, text in
                owner.postWriteRequestModel.content = text
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            input.postContentText,
            photoImageObservableList
        )
        .subscribe(with: self) { owner, postCreateData in
            let model = PostWriteRequest(
                title: "",
                content: postCreateData.0,
                file: postCreateData.1,
                content1: "test1",
                content2: "test2"
            )
            owner.postWriteRequestObservable.onNext(model)
        }
        .disposed(by: disposeBag)
        
        input.postCreateButtonTap
            .withLatestFrom(postWriteRequestObservable)
            .flatMap {
                Network.shared.requestFormDataConvertible(
                    router: .post(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? "",
                        model: $0
                    )
                )
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    print("======", data)
                    owner.successPostCreate.accept(true)
                case .failure(let error):
                    print("======", error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            postWriteRequestObservable: postWriteRequestObservable,
            photoImageObservableList: photoImageObservableList,
            successPostCreate: successPostCreate
        )
    }
}
