//
//  Extension+ViewModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/16/23.
//

import Foundation

extension ViewModelType {
    func checkAccessToken() -> String {
        if let token = KeyChain.read(key: APIConstants.accessToken) {
            print("🔑 토큰 확인: \(token)")
            return token
        } else {
            print("❌ 토큰 확인 실패")
            return ""
        }
    }
}
