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
    var nextCursor: LandingValue
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct LandingValue: Decodable {
    let stringValue: String?
    let intValue: Int?
    
    init(stringValue: String? = nil, intValue: Int? = nil) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // String decode 시도
        if let value = try? container.decode(String.self) {
            self = .init(stringValue: value)
            return
        }

        // Int decode 시도
        if let value = try? container.decode(Int.self) {
            self = .init(intValue: value)
            return
        }

        throw DecodingError.typeMismatch(
            PostListResponse.self,
            DecodingError.Context(codingPath: decoder.codingPath,
                                  debugDescription: "Type is not matched",
                                  underlyingError: nil)
        )
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
    let creator: Creator
    let comments: [Comments]
    
    enum CodingKeys: String, CodingKey {
        case _id, time, likes, image, title, content
        case productID = "product_id"
        case creator
        case comments
    }
}


struct Creator: Decodable {
    let _id: String
    let nick: String
}

struct Comments: Decodable {
    let _id: String
    let content: String
    let time: String
    let creator: Creator
}

