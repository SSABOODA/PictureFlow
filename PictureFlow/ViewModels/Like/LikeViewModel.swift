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
    var initTokenObservable = PublishSubject<String>()
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    func fetchProfileMyPostListData() {
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("🔑 토큰 확인: \(token)")
            initTokenObservable.onNext(token)
        } else {
            print("토큰 확인 실패")
        }
    }
    
}
