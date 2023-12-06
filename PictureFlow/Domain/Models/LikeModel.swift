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

/*
 좋아요한 게시글 조회
 */

struct LikedPostListRequest: Encodable {
    let next: String
    let limit: String
}

struct LikedPostListResponse: Decodable {
    let data: [LikedPostList]
    var nextCursor: String
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
    let product_id: String?
}


/*
 {
     "data": [
         {
             "likes": ["655658cc3913fe98de4b8290", "655657ef3913fe98de4b8261"],
             "image": [
                 "uploads/posts/1700158027466.jpeg",
                 "uploads/posts/1700158027486.gif",
             ],
             "hashTags": [],
             "comments": [
                 {
                     "_id": "65565b343913fe98de4b8329",
                     "content": " ( )",
                     "time": "2023-11-16T18:11:00.659Z",
                     "creator": {
                         "_id": "655658cc3913fe98de4b8290",
                         "nick": " ",
                         "profile": "uploads/profiles/1700158510000.jpg",
                     },
                 },
                 {
                     "_id": "65565ad83913fe98de4b831e",
                     "content": " lslp !",
                     "time": "2023-11-16T18:09:28.824Z",
                     "creator": {
                         "_id": "655657ef3913fe98de4b8261",
                         "nick": " ",
                         "profile": "uploads/profiles/1700158510000.jpg",
                     },
                 },
             ],
             "_id": "65565a4b3913fe98de4b8302",
             "creator": {
                 "_id": "6556566d3913fe98de4b8239",
                 "nick": " ",
                 "profile": "uploads/profiles/1700158606703.jpeg",
             },
             "time": "2023-11-16T18:07:07.490Z",
             "title": " ",
             "content": " ",
             "content1": " ",
             "content2": " ",
             "content3": "~",
             "content4": " !",
             "content5": " ",
             "product_id": "Yummy_sesac",
         },
         
         {
             "likes": ["655658cc3913fe98de4b8290", "655657ef3913fe98de4b8261"],
             "image": [],
             "hashTags": [],
             "comments": [],
             "_id": "655659b83913fe98de4b82d2",
             "creator": {"_id": "6556566d3913fe98de4b8239", "nick": " "},
             "time": "2023-11-16T18:04:40.346Z",
         },
     ],
     "next_cursor": "655659b83913fe98de4b82d2",
 }

 */
