//
//  SignIn.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/12/23.
//

import Foundation

/*
 로그인
 */
struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
    let refreshToken: String
}
