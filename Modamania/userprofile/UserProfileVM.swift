//
//  UserProfileVM.swift
//  Modamania
//
//  Created by macbook  on 25.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class UserProfileVM{
    
    private let profileData = PublishSubject<MyProfileUserModel>()
    private let pageLoading = BehaviorRelay<Bool>(value: true)
    private let btnLoading = BehaviorRelay<Bool>(value: true)
    private var userId: String
    private let disposeBag = DisposeBag()
    
    func getProfileData() -> PublishSubject<MyProfileUserModel>{
        return profileData
    }
    func getPageLoading() -> BehaviorRelay<Bool>{
        return pageLoading
    }
    func getBtnLoading() -> BehaviorRelay<Bool>{
        return btnLoading
    }
    init(userId: String) {
        self.userId = userId
        fetchProfile()
    }
    
    func followUser(){
         self.btnLoading.accept(true)
        ApiClient.followUser(userId: userId)
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                self.fetchProfile()
            }).disposed(by: disposeBag)
        
    }
    
    func unFollowUser(){
         self.btnLoading.accept(true)
        ApiClient.unFollowUser(userId: userId)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                self.fetchProfile()
            }).disposed(by: disposeBag)
        
    }
    
    func fetchProfile(){
        
        ApiClient.getUserProfile(userId: userId)
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                (model) in
                self.pageLoading.accept(false)
                self.profileData.onNext(model.user)
                self.btnLoading.accept(false)
            }).disposed(by: disposeBag)
        
    }
    
}
