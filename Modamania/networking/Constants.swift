//
//  Constants.swift
//  Modamania
//
//  Created by macbook  on 23.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
class Constants {
    
    static let BASE_URL = "https://modamania.herokuapp.com/api/"
    
    
    
    //The content type (JSON)
    enum ContentType: String {
        case json = "application/json"
        case multipart = "multipart/form-data"
    }
    
    //The header fields
    enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
        
    }
    
    
}
