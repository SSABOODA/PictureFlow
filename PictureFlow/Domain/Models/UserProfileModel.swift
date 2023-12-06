//
//  UserProfile.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/6/23.
//

import Foundation

/*
 유저 프로필 조회
 */
struct UserProfileRetrieveRequest: Encodable {
    
}

struct UserProfileRetrieveResponse: Decodable {
    let posts: [String]
    let followers: UserInfo
    let following: UserInfo
    let _id: String
    let email: String
    let nick: String
    let phoneNum: String
    let birthDay: String
    let profile: String
}

struct UserInfo: Decodable {
    let _id: String
    let nick: String
    let profile: String
}






