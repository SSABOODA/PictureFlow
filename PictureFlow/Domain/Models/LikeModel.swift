//
//  LikeModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/6/23.
//

import Foundation

/*
 좋아요
 */
struct LikeRetrieveResponse: Decodable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}




