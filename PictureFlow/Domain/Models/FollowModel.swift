//
//  FollowModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/13/23.
//

import Foundation

/*
 팔로우
 */

struct FollowResponse: Decodable {
    let user: String
    let following: String
    let followingStatus: String
    
    enum CodingKeys: String, CodingKey {
        case user
        case following
        case followingStatus = "following_status"
    }
}


