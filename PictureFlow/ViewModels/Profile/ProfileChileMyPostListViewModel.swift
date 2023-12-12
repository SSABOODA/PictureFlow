//
//  ProfileChileMyPostListViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/12/23.
//

import Foundation
import RxSwift

final class ProfileChileMyPostListViewModel: ViewModelType {
    struct Input {}
    
    struct Output {}
    
    var disposeBag = DisposeBag()
    var postList = [PostList]()
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
