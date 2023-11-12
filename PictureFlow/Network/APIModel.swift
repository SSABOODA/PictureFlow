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
struct SignUpReqeust: Encodable {
    let email: String
    let password: String
    let nickname: String
    let phoneNumber: String?
    let birthday: String?
}

struct SignUpResponse: Decodable {
    let _id: String
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
