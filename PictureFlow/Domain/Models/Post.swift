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
    var likes: [String]
    var image: [String]
    var hashTags: [String]
    let comments: [Comment]
    let _id: String
    let creator: Creator
    let time, title: String
    let content, content1, content2: String
    let product_id: String
}

struct Comment: Decodable {
    let id, content, time: String
    let creator: Creator
}

struct Creator: Decodable {
    let id, nick: String
}
