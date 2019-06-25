//
//  LoginModel.swift
//  Modamania
//
//  Created by macbook  on 23.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation

/*
 {
 "user": {
 "name_surname": "Emin Kişi",
 "username": "meksconway",
 "user_id": "5d0e0d93c7bb8100344fbbce"
 },
 "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im11aGFtbWVkZW1pbmtpc2lAZ21haWwuY29tIiwidXNlcl9pZCI6IjVkMGUwZDkzYzdiYjgxMDAzNDRmYmJjZSIsInVzZXJuYW1lIjoibWVrc2NvbndheSIsInVzZXJfZm9sZGVyIjoiZGVmYXVsdC5qcGVnIiwibmFtZV9zdXJuYW1lIjoiRW1pbiBLacWfaSIsImlhdCI6MTU2MTI4NjAwNSwiZXhwIjoxNTY2NDcwMDA1fQ.v2uOMwpyTyf0oWB7JJ0yJf51HVx_vqCWQgwa0U0TsIo"
 }
 */

struct LoginModel: Codable {
    
    let token: String?
    let user: LoginUserModel?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case user = "user"
        case message = "message"
    }
    
}

struct LoginUserModel: Codable {
    let nameSurname: String
    let username: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case nameSurname = "name_surname"
        case username = "username"
        case userId = "user_id"
    }
}
