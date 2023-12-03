//
//  CommentModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/3/23.
//

import Foundation

struct CommentCreateRequest: Codable {
    let content: String
}


struct CommentCreateResponse: Decodable {
    let _id: String
    let time: String
    let content: String
    let creator: Creator
}


