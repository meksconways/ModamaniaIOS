//
//  FeedModel.swift
//  Modamania
//
//  Created by macbook  on 24.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

/*
 [
 {
 "_id": "5d0e0d93c7bb8100344fbbce",
 "posts": {
 "owner": {
 "user_folder": "default.jpeg",
 "_id": "5d0e0d93c7bb8100344fbbce",
 "username": "meksconway",
 "name_surname": "Emin Kişi"
 },
 "likeCount": 0,
 "isTrending": false,
 "likeStatus": false,
 "comment_count": 0,
 "viewed_count": 0,
 "created_date": "2019-06-23T12:14:56.542Z",
 "post_image": "https://modamaniaapp.s3.amazonaws.com/1561293718387",
 "_id": "5d0f7397f39f5f00346ea727",
 "description": "4. post",
 "likes": [],
 "comments": [],
 "viewed_people": []
 }
 }
 ]
 */

import Foundation

struct MyFeedModel: Codable {
    
    let message: String?
    let id: String?
    let posts: FeedPostModel?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case message = "message"
        case posts = "posts"
    }
    
}

struct FeedPostModel: Codable {
    
    let owner: FeedOwnerModel
    let likeCount: Int
    let isTrending: Bool
    let likeStatus: Bool
    let commentCount: Int
    let viewedCount: Int
    let createdDate: String
    let postImage: String
    let postId: String
    let description: String
    // likes, comments, viewedPeople yapılcak.!!
    
    enum CodingKeys: String, CodingKey {
        case owner = "owner"
        case likeCount = "likeCount"
        case isTrending = "isTrending"
        case likeStatus = "likeStatus"
        case commentCount = "comment_count"
        case viewedCount = "viewed_count"
        case createdDate = "created_date"
        case postImage = "post_image"
        case postId = "_id"
        case description = "description"
        
    }
    
}

struct FeedOwnerModel: Codable {
    
    let userFolder: String
    let userId: String
    let username: String
    let nameSurname: String
    
    enum CodingKeys: String, CodingKey {
        case userFolder = "user_folder"
        case userId = "_id"
        case username = "username"
        case nameSurname = "name_surname"
    }
    
}

