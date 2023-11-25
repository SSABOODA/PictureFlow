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
    init(original: PostDetailModel, items: [Comments]) {
        self = original
        self.items = items
    }
}

final class PostDetailViewModel: ViewModelType {
    struct Input {
    }
    
    struct Output {
        let postObservableItem: PublishSubject<[PostDetailModel]>
        let postDataList: [PostDetailModel]
    }
    
    var disposeBag = DisposeBag()
    var postList: PostList?
    var postObservableItem = PublishSubject<[PostDetailModel]>()
    var postDataList: [PostDetailModel] = []
    
    func transform(input: Input) -> Output {
        
        if let postList {
            postDataList.insert(
                PostDetailModel(
                    header: postList,
                    items: [
                        Comments(_id: "_idT", content: "123", time: "time", creator: Creator(_id: "idC", nick: "ggg"))
                    ]
                ),
                at: 0
            )
        }
        
        
        return Output(
            postObservableItem: postObservableItem,
            postDataList: postDataList
        )
    }
}
