//
//  LoginVM.swift
//  Modamania
//
//  Created by macbook  on 17.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LoginVM {
    
    private let loginData = PublishSubject<LoginModel>()
    private let loading = BehaviorRelay<Bool>(value: false)
    private let errorMsg = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()
    
    
    func getErrorMsg() -> BehaviorRelay<String?>{
        return errorMsg
    }
    
    func clearErrorMsg(){
        errorMsg.accept(nil)
    }
    
    func getLoginData() -> PublishSubject<LoginModel>{
        return loginData
    }
    
    func getLoading() -> BehaviorRelay<Bool>{
        return loading
    }
    
    func login(username:String, password: String){
        self.loading.accept(true)
        ApiClient.login(username: username, password: password)
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (data) in
                if data.message != nil{
                    self.loading.accept(false)
                    self.errorMsg.accept(data.message)
                    return
                }
                
                self.saveData(userId: data.user!.userId, token: data.token!)
                
                self.loginData.onNext(data)
                self.loading.accept(false)
            })
        .disposed(by: disposeBag)
        
    }
    
    func saveData(userId: String,token: String){
        
        UserDefaults.standard.set(userId, forKey: "user_id")
        UserDefaults.standard.set(token, forKey: "token")
        
    }
    
    
}
