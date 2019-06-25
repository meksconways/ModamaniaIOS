//
//  ProfileVM.swift
//  Modamania
//
//  Created by macbook  on 25.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ProfileVM{
    
    private let profileData = PublishSubject<MyProfileUserModel>()
    private let pageLoading = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    func getProfileData() -> PublishSubject<MyProfileUserModel>{
        return profileData
    }
    func getPageLoading() -> BehaviorRelay<Bool>{
        return pageLoading
    }
    
    func fetchProfile(){
        
        ApiClient.getMyProfile()
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                self.pageLoading.accept(false)
                self.profileData.onNext(model.user)
            }).disposed(by: disposeBag)
        
    }
    
    
}
