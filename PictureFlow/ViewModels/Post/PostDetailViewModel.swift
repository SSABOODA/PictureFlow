//
//  PostDetailViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/22/23.
//

import Foundation
import RxSwift
import RxDataSources

struct PostDetailModel {
    var header: PostList
    var items: [Comments] = []
}

extension PostDetailModel: SectionModelType {
    init(
        original: PostDetailModel,
        items: [Comments]
    ) {
        self = original
        self.items = items
    }
}

final class PostDetailViewModel: ViewModelType {
    struct Input {
    }
    
    struct Output {
        let postObservableItem: PublishSubject<[PostDetailModel]>
    }
    
    var disposeBag = DisposeBag()

    var postList: PostList?
    var postDataList: [PostDetailModel] = []
    var postObservableItem = PublishSubject<[PostDetailModel]>()
    
    let tokenObservable = BehaviorSubject<String>(value: "")
    let commentCreateSuccess = BehaviorSubject(value: false)

    func transform(input: Input) -> Output {

        if let postList {
            postDataList.insert(
                PostDetailModel(
                    header: postList,
                    items: []
                ), at: 0
            )
            _ = postList.comments.map { postDataList[0].items.append($0) }
        }
                
        return Output(
            postObservableItem: postObservableItem
        )
    }
    
    func updateDateSource() {
        let token = self.checkAccessToken()
        tokenObservable.onNext(token)
    }
}
