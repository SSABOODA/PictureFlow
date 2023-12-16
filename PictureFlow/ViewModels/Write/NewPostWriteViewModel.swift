//
//  NewPostWriteViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/15/23.
//

import UIKit
import RxSwift
import RxCocoa

class NewPostWriteViewModel: ViewModelType {
    struct Input {
        let postCreateButtonTap: ControlEvent<Void>
        let postContentText: ControlProperty<String>
    }
    
    struct Output {
        let photoImageObservableList: BehaviorSubject<[UIImage]>
        let postWriteRequestObservable: PublishSubject<PostWriteRequest>
        let successPostCreate: BehaviorRelay<Bool>
        let userProfileObservable: PublishSubject<UserInfo>
    }
    
    var disposeBag = DisposeBag()
    
    var postWriteRequestModel = PostWriteRequest(
        title: "",
        content: "",
        file: [UIImage](),
        content1: "",
        content2: ""
    )
    
    var initTokenObservable = PublishSubject<String>()
    
    var userProfileObservable = PublishSubject<UserInfo>()
    
    var photoImageList = [UIImage]()
    var photoImageObservableList = BehaviorSubject<[UIImage]>(value: [])
    var postWriteRequestObservable = PublishSubject<PostWriteRequest>()
    var successPostCreate = BehaviorRelay(value: false)

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
                    print(error)
                }
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
                content1: "",
                content2: ""
            )
            owner.postWriteRequestObservable.onNext(model)
        }
        .disposed(by: disposeBag)
            
        input.postContentText
            .subscribe(with: self) { owner, text in
                owner.postWriteRequestModel.content = text
            }
            .disposed(by: disposeBag)
        
        input.postCreateButtonTap
            .withLatestFrom(postWriteRequestObservable)
            .flatMap {
                Network.shared.requestFormDataConvertible(
                    type: PostWriteResponse.self,
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
            photoImageObservableList: photoImageObservableList,
            postWriteRequestObservable: postWriteRequestObservable,
            successPostCreate: successPostCreate,
            userProfileObservable: userProfileObservable
        )
    }
}
