//
//  UserVerification.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import Foundation

/*
 회원가입
 /join
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
    let _id: String
    let token: String
    let refreshToken: String
}

/*
 이메일 유효성 검증
 /validation/email
 */
struct ValidationRequest: Encodable {
    var email: String
}

struct ValidationResponse: Decodable {
    var message: String
}

/*
 AccessToken 갱신
 /refresh
 */
struct TokenRequest: Encodable {
}

struct TokenResponse: Decodable {
    let token: String
}

/*
 탈퇴
 */

struct WithdrawResponse: Decodable {
    let _id: String
    let email: String
    let nick: String
}
