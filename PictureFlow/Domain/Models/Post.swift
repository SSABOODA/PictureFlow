//
//  Post.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import Foundation

/*
 게시글 작성(post)
 /post
 */

struct PostRequest: Encodable {
    var title: String
    var content: String
    var file: String // TODO: 파일 로직 처리 수정 필요
    var product_id: String
    var content1: String?
    var content2: String?
    var content3: String?
    var content4: String?
    var content5: String?
}

struct PostResponse: Decodable {
    
}

/*
 게시글 조회(post)
 /post
 */

struct PostListRequest: Encodable {
    let next: String?
    let limit: String?
    let product_id: String?
}

struct PostListResponse: Decodable {
    let data: [PostList]
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct PostList: Decodable {
    let _id: String
    let likes: [String]
    let image: [String]
    let title: String?
    let content: String?
    let time: String
    let productID: String?
    
    enum CodingKeys: String, CodingKey {
        case _id, time, likes, image, title, content
        case productID = "product_id"
    }
}
