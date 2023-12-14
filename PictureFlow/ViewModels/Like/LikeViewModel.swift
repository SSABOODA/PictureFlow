//
//  LikeViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import Foundation
import RxSwift

final class LikeViewModel: ViewModelType {
    struct Input {}
    struct Output {}
    
    var disposeBag = DisposeBag()
    func transform(input: Input) -> Output {
        return Output()
    }
    
}
