//
//  Token.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/12/23.
//

import Foundation

/*
 토큰
 */
struct TokenRequest: Encodable {
}

struct TokenResponse: Decodable {
    let token: String
}
