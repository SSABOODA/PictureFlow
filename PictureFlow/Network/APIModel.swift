//
//  APIModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/11/23.
//

import Foundation

/*
 회원가입
 */
struct JoinReqeust: Encodable {
    let email: String
    let password: String
}

struct JoinResponse: Decodable {
//    let _id: String
    let email: String
    let nick: String
}


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
