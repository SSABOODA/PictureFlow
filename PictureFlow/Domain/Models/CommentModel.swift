//
//  CommentModel.swift
//  PictureFlow
//
//  Created by 한성봉 on 12/3/23.
//

import Foundation

/*
 댓글 작성
 */
struct CommentCreateRequest: Codable {
    let content: String
}


struct CommentCreateResponse: Decodable {
    let _id: String
    let time: String
    let content: String
    let creator: Creator
}

/*
 댓글 수정
 */
struct CommentUpdateRequest: Codable {
    let content: String
}

struct CommentUpdateResponse: Decodable {
    let _id: String
    let content: String
    let time: String
    let creator: Creator
}

/*
 댓글 삭제
 */

struct CommentDeleteResponse: Decodable {
    let postId: String
    let commentId: String
    
    enum CodingKeys: String, CodingKey {
        case postId = "postID"
        case commentId = "commentID"
    }
}

