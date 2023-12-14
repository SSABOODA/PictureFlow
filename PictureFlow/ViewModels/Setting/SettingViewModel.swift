//
//  SettingViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/14/23.
//

import UIKit
import RxSwift
import RxCocoa

struct SettingItem {
    let name: String
    let imageString: String?
    
    var uiImage: UIImage? {
        return UIImage(systemName: imageString ?? "")
    }
}

final class SettingViewModel: ViewModelType {
    struct Input {}
    struct Output {
        let settingItemListObservable: PublishSubject<[SettingItem]>
        let withdrawUserInfo: PublishSubject<WithdrawResponse>
        let errorResponse: PublishSubject<CustomErrorResponse>
    }
    
    var disposeBag = DisposeBag()
    
    let settingItemList = [
        SettingItem(name: "친구 팔로우 및 초대", imageString: "person.badge.plus"),
        SettingItem(name: "알림", imageString: "alarm"),
        SettingItem(name: "좋아요", imageString: "heart"),
        SettingItem(name: "개인정보 보호", imageString: "lock"),
        SettingItem(name: "계정", imageString: "person.crop.circle.fill"),
//        SettingItem(name: "도움말", image: nil),
        SettingItem(name: "정보", imageString: "info.circle"),
        
        SettingItem(name: "로그아웃", imageString: nil),
        SettingItem(name: "회원탈퇴", imageString: nil),
    ]
    
    var settingItemListObservable = PublishSubject<[SettingItem]>()
    var isWithdraw = PublishSubject<Bool>()
    var withdrawUserInfo = PublishSubject<WithdrawResponse>()
    var errorResponse = PublishSubject<CustomErrorResponse>()
    
    func transform(input: Input) -> Output {
        
        isWithdraw
            .flatMap { _ in
                Network.shared.requestObservableConvertible(
                    type: WithdrawResponse.self,
                    router: .withdraw(
                        accessToken: KeyChain.read(key: APIConstants.accessToken) ?? ""
                    )
                )
            }
            .subscribe(with: self) { owner, response in
                switch response {
                case .success(let data):
                    owner.withdrawUserInfo.onNext(data)
                case .failure(let error):
                    owner.errorResponse.onNext(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            settingItemListObservable: settingItemListObservable,
            withdrawUserInfo: withdrawUserInfo,
            errorResponse: errorResponse
        )
    }
}
