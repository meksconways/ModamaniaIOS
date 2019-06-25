//
//  ErrorModel.swift
//  Modamania
//
//  Created by macbook  on 23.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation

struct ErrorModel: Codable {
    
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
    }
    
}

struct PostUploadModel: Codable {
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
    }
}
