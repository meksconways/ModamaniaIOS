//
//  ApiClient.swift
//  Modamania
//
//  Created by macbook  on 23.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class ApiClient {
    
    
    static func login(username: String, password: String) -> Observable<LoginModel> {
        return request(ApiRouter.login(username: username, password: password))
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    static func signUp(fullname: String,username: String,email: String, password: String) -> Observable<LoginModel>{
        return request(ApiRouter.signUp(fullName: fullname, password: password, username: username, email: email))
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    static func getFeed() -> Observable<[MyFeedModel]>{
        return request(ApiRouter.getFeed).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    static func uploadPost(postImage: UIImage, description: String) -> Observable<PostUploadModel>{
        return request(ApiRouter.createPost(postImage: postImage, description: description))
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    static func getMyProfile() -> Observable<MyProfileModel> {
        return request(ApiRouter.getMyProfile).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    static func getUserProfile(userId: String) -> Observable<MyProfileModel> {
        return request(ApiRouter.getUserProfile(userId: userId))
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    static func followUser(userId: String) -> Observable<PostUploadModel>{
        return request(ApiRouter.followUser(userId: userId))
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    static func unFollowUser(userId: String) -> Observable<PostUploadModel>{
        return request(ApiRouter.unFollowUser(userId: userId))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    //-------------------------------------------------------------------------------------------------
    //MARK: - Observable result geliyor
    private static func request<T: Codable> (_ urlConvertible: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            
            let request = AF.request(urlConvertible).responseDecodable { (response: DataResponse<T>) in
                
                
                switch response.result {
                    
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                    
                case .failure(let error):
                    switch response.response?.statusCode {
                    case 403:
                        observer.onError(ApiError.forbidden)
                    case 404:
                        observer.onError(ApiError.notFound)
                    case 409:
                        observer.onError(ApiError.conflict)
                    case 500:
                        observer.onError(ApiError.internalServerError)
                    default:
                        observer.onError(error)
                    }
                   
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    
}
