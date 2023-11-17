//
//  Validation.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/16/23.
//

import Foundation

/*
 이메일 유효성 검증
 */
struct ValidationRequest: Encodable {
    var email: String
}

struct ValidationResponse: Decodable {
    var message: String
}
