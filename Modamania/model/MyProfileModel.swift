//
//  MyProfileModel.swift
//  Modamania
//
//  Created by macbook  on 25.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

/*
 
 {
 "user": {
 "user_folder": "default.jpeg",
 "following_count": 0,
 "follower_count": 0,
 "total_post_count": 8,
 "is_trending": 0,
 "total_like": 0,
 "total_viewed": 0,
 "gender": 1,
 "_id": "5d0e0d93c7bb8100344fbbce",
 "username": "meksconway",
 "name_surname": "Emin Kişi",
 "followers": [],
 "following": [],
 "posts": [
 {
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
 "created_date": "2019-06-23T11:02:02.422Z",
 "post_image": "https://modamaniaapp.s3.amazonaws.com/1561287743052",
 "likes": [],
 "comments": [],
 "viewed_people": [],
 "_id": "5d0f5c406a99720034b96256",
 "description": "Merhaba ilk post! #helloworld"
 },
 {
 "owner": {
 "user_folder": "default.jpeg",
 "_id": "5d0e0d93c7bb8100344fbbce",
 "username": "meksconway",
 "name_surname": "Emin Kişi"
 }
 ],
 "__v": 10
 }
 }
 */

import Foundation

struct MyProfileModel: Codable {
    let user: MyProfileUserModel
    
    enum CodingKeys: String, CodingKey {
        case user = "user"
    }
}

struct MyProfileUserModel: Codable {
    /*
     user_folder": "default.jpeg",
     "following_count": 0,
     "follower_count": 0,
     "total_post_count": 8,
     "is_trending": 0,
     "total_like": 0,
     "total_viewed": 0,
     "gender": 1,
     "_id": "5d0e0d93c7bb8100344fbbce",
     "username": "meksconway",
     "name_surname": "Emin Kişi",
     "followers": [],
     "following": [],
     */
    let userFolder: String
    let followersCount: Int
    let followingCount: Int
    let postCount: Int
    let totalLike: Int
    let totalViewed: Int
    let userId: String
    let username: String
    let fullName: String
    let post: [MyProfilePostModel]
    let followers : [MyProfileFollowersModel]
    let following: [MyProfileFollowersModel]
    
    
    enum CodingKeys: String, CodingKey {
        case userFolder = "user_folder"
        case followersCount = "follower_count"
        case followingCount = "following_count"
        case postCount = "total_post_count"
        case totalLike = "total_like"
        case totalViewed = "total_viewed"
        case userId = "_id"
        case username = "username"
        case fullName = "name_surname"
        case post = "posts"
        case followers = "followers"
        case following = "following"
    }
    
}

struct MyProfileFollowersModel: Codable {
    
//    "following": [
//    {
//    "user_folder": "https://modamaniaapp.s3.amazonaws.com/1561472591311",
//    "_id": "5d0e0d93c7bb8100344fbbce",
//    "usernameX": "meksconway",
//    "name_surname": "Emin Kişi"
//    }
//    ],
    
    let userFolder: String
    let userId: String
    let username: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case userFolder = "user_folder"
        case userId = "_id"
        case username = "usernameX"
        case fullName = "name_surname"
    }
    
}

struct MyProfilePostModel: Codable {
    /*
     {
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
     "created_date": "2019-06-23T11:02:02.422Z",
     "post_image": "https://modamaniaapp.s3.amazonaws.com/1561287743052",
     "likes": [],
     "comments": [],
     "viewed_people": [],
     "_id": "5d0f5c406a99720034b96256",
     "description": "Merhaba ilk post! #helloworld"
     */
    let owner: MyProfileOwnerModel
    let likeCount: Int
    let commentCount: Int
    let viewedCount: Int
    let createdDate: String
    let postImage: String
    let postId: String
    let description: String
    // lvc yapılcak!
    
    enum CodingKeys: String,CodingKey {
        case owner = "owner"
        case commentCount = "comment_count"
        case likeCount = "likeCount"
        case viewedCount = "viewed_count"
        case createdDate = "created_date"
        case postImage = "post_image"
        case postId = "_id"
        case description = "description"
    }
    
    
}

struct MyProfileOwnerModel: Codable {
    let userFolder: String
    let userId: String
    let username: String
    let fullName: String
    
    enum CodingKeys: String,CodingKey {
        case userFolder = "user_folder"
        case userId = "_id"
        case username = "username"
        case fullName = "name_surname"
    }
}
