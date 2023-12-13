//
//  UserProfile.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/6/23.
//

import UIKit

/*
 유저 프로필 Domain 구조체
 */

struct UserProfileDomainData {
    let posts: [String]
    let followers: [UserInfo]
    let following: [UserInfo]
    let _id: String
    let email: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
    let profile: String?
}

/*
 유저 프로필 조회
 */
struct UserProfileRetrieveRequest: Encodable {
    
}

struct UserProfileRetrieveResponse: Decodable {
    let posts: [String]
    let followers: [UserInfo]
    let following: [UserInfo]
    let _id: String
    let email: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
    let profile: String?
}

struct UserInfo: Decodable {
    let _id: String
    let nick: String
    let profile: String?
}

/*
 유저 프로필 수정
 */

struct UserProfileUpdateRequest {
    let nick: String
    let phoneNum: String
    let birthDay: String
    let profile: UIImage
}

struct UserProfileUpdateResponse: Decodable {
    let posts: [String]
    let followers: [UserInfo]
    let following: [UserInfo]
    let _id: String
    let email: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
    let profile: String?
}


/*
 다른 유저 프로필 조회
 */

struct OtherUserProfileRetrieve: Decodable {
    let posts: [String]
    let followers: [UserInfo]
    let following: [UserInfo]
    let _id: String
    let nick: String
    let profile: String?
}

