//
//  ApiRouter.swift
//  Modamania
//
//  Created by macbook  on 23.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import Alamofire

enum ApiRouter: URLRequestConvertible{
    
    
    case login(username: String, password: String)
    case signUp(fullName: String,password: String,username: String,email:String)
    case getFeed
    case createPost(postImage: UIImage, description: String)
    case getMyProfile
    case getUserProfile(userId: String)
    case followUser(userId: String)
    case unFollowUser(userId: String)
    
    
    
    func asURLRequest() throws -> URLRequest {
        let url = try Constants.BASE_URL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path)) // loginse farklı header kur!
        //Http method
        urlRequest.httpMethod = method.rawValue
        
        //urlRequest.headers = headers
       
        urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.contentType.rawValue)
        
        if path == "createPost"{
            urlRequest.setValue(Constants.ContentType.multipart.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.acceptType.rawValue)
        }else{
             urlRequest.setValue(Constants.ContentType.json.rawValue, forHTTPHeaderField: Constants.HttpHeaderField.acceptType.rawValue)
        }
        
        
        if path != "login" && path != "register"{
            
            if let token = UserDefaults.standard.string(forKey: "token"){
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: Constants.HttpHeaderField.authentication.rawValue)
            }
            
        }
        
        
        
        //Encoding
        let encoding: ParameterEncoding = {
            switch method {
            case .post:
                return JSONEncoding.default
            default:
                return URLEncoding.default
            }
        }()
        
     
        
        return try encoding.encode(urlRequest, with: parameters)
    }
    
    // headers için
    private var headers: HTTPHeaders {
        switch self{
        case .login:
            return [Constants.ContentType.json.rawValue:Constants.HttpHeaderField.acceptType.rawValue,
                    Constants.ContentType.json.rawValue:Constants.HttpHeaderField.acceptEncoding.rawValue,
                    Constants.ContentType.json.rawValue:Constants.HttpHeaderField.contentType.rawValue]
        default:
            return [Constants.HttpHeaderField.authentication.rawValue:"Bearer \(UserDefaults.standard.string(forKey: "token")!)",
                Constants.ContentType.json.rawValue:Constants.HttpHeaderField.acceptType.rawValue,
                Constants.ContentType.json.rawValue:Constants.HttpHeaderField.contentType.rawValue]
        }
    }
    
    
    // http method için
    private var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signUp:
            return .post
        case .getFeed:
            return .get
        case .createPost:
            return .post
        case .getMyProfile:
            return .get
        case .getUserProfile:
            return .post
        case .followUser:
            return .post
        case .unFollowUser(let userId):
            return .post
        }
    }
    
    // endpoint path için
    private var path: String {
        switch self {
        case .login:
            return "login"
        case .signUp:
            return "register"
        case .getFeed:
            return "getFeeds"
        case .createPost:
            return "createPost"
        case .getMyProfile:
            return "myProfile"
        case .getUserProfile:
            return "user"
        case .followUser:
            return "followUser"
        case .unFollowUser(let userId):
            return "unfollowUser"
        }
    }
    
    // parametreler için: (parametre olmaya da bilir)
    private var parameters: Parameters {
        switch self {
        case .login(let username, let password):
            return ["username":username,"password":password]
        case .signUp(let fullName, let password, let username, let email):
            return ["name_surname":fullName,"password":password,"username":username,"email":email]
        case .getFeed:
            return [:]
        case .createPost(let postImage, let description):
            return ["post_image":postImage, "description":description]
        case .getMyProfile:
            return [:]
        case .getUserProfile(let userId):
            return ["user_id":userId]
        case .followUser(let userId):
            return ["user_id":userId]
        case .unFollowUser(let userId):
            return ["user_id":userId]
        }
    }
    
    
    
    
    
    
}
enum ApiError: Error {
    case forbidden              //Status code 403
    case notFound               //Status code 404
    case conflict               //Status code 409
    case internalServerError    //Status code 500
}
