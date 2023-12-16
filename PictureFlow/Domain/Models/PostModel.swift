//
//  Post.swift
//  PictureFlow
//
//  Created by 한성봉 on 11/17/23.
//

import UIKit

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
    var data: [PostList]
    var nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct PostList: Decodable {
    let _id: String
    var likes: [String]
    var image: [String]
    var title: String?
    var content: String?
    let time: String
    let productID: String?
    let creator: Creator
    let comments: [Comments]
    let hashTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case _id, time, likes, image, title, content
        case productID = "product_id"
        case creator
        case comments
        case hashTags
    }
}

struct Creator: Decodable {
    let _id: String
    let nick: String
    let profile: String?
}

struct Comments: Decodable {
    let _id: String
    var content: String
    let time: String
    let creator: Creator
}


/*
 게시글 작성(Create)
 */

struct PostWriteRequest {
    var title: String
    var content: String
    var file: [UIImage] = []
    var productId: String = "picture_flow"
    var content1: String = ""
    var content2: String = ""
    var content3: String = ""
    var content4: String = ""
    var content5: String = ""
}

struct PostWriteResponse: Decodable {
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

/*
 게시글 수정
 */

struct PostUpdateRequest {
    var title: String
    var content: String
    var file: [UIImage] = []
    var productId: String = "picture_flow"
    var content1: String = ""
    var content2: String = ""
    var content3: String = ""
    var content4: String = ""
    var content5: String = ""
}

struct PostUpdateResponse: Decodable {
    let _id: String
    let likes: [String]
    let image: [String]
    let title: String?
    let content: String?
    let time: String
    let productID: String?
    let creator: Creator
    let comments: [Comments]
    let hashTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case _id, time, likes, image, title, content
        case productID = "product_id"
        case creator
        case comments
        case hashTags
    }
}


/*
 게시글 삭제
 */

struct PostDeleteResponse: Decodable {
    let _id: String
}


/*
 유저별 작성한 게시글 조회
 */

struct UserProfileMyPostListResponse: Decodable {
    let data: [PostList]
    var nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
    
}

/*
 좋아요한 게시글 조회
 */

struct LikedPostListRequest: Encodable {
    let next: String
    let limit: String
}

struct LikedPostListResponse: Decodable {
    let data: [PostList]
    var nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct LikedPostList: Decodable {
    let likes: [String]
    let image: [String]
    let hashTags: [String]
    let comments: Comments
    let _id: String
    let creator: Creator
    let time: String
    let title: String
    let content: String?
    let content1: String?
    let content2: String?
    let content3: String?
    let content4: String?
    let content5: String?
    let productID: String?
    
    enum CodingKeys: String, CodingKey {
        case likes, image, hashTags
        case _id, time, title
        case content, content1, content2, content3, content4, content5
        case productID = "product_id"
        case creator
        case comments
    }
}

/*
 해시태그 검색
 */

struct HashTagPostResponse: Decodable {
    let data: [PostList]
    var nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}


/*
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
 */
