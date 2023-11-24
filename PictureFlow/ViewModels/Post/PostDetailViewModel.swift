//
//  PostDetailViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/22/23.
//

import Foundation
import RxSwift

final class PostDetailViewModel: ViewModelType {
    struct Input {
    }
    
    struct Output {
        let postItem: PublishSubject<PostList>
    }
    
    var disposeBag = DisposeBag()
    var postList: PostList?
    var postItem = PublishSubject<PostList>()
    
    func transform(input: Input) -> Output {
        return Output(postItem: postItem)
    }
}
