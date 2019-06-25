//
//  SignUpVM.swift
//  Modamania
//
//  Created by macbook  on 23.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SignUpVM {
    
    private let loading = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    private let errorMessage = BehaviorRelay<String?>(value: nil)
    private let routeMain = PublishSubject<Bool>()
    
    func getLoading() -> BehaviorRelay<Bool> {
        return loading
    }
    
    func getErrorMsg() -> BehaviorRelay<String?> {
        return errorMessage
    }
    
    func getRouteMain() -> PublishSubject<Bool>{
        return routeMain
    }
    
    func signUp(fullName: String, username: String, password: String, email: String){
        self.loading.accept(true)
        ApiClient.signUp(fullname: fullName, username: username, email: email, password: password)
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                
                if model.message != nil{
                    self.errorMessage.accept(model.message)
                    self.loading.accept(false)
                    return
                }
                
                
                self.saveData(userId: model.user!.userId, token: model.token!)
               
            }).disposed(by: disposeBag)
        
        
    }
    
    func saveData(userId: String,token: String){
        
        UserDefaults.standard.set(userId, forKey: "user_id")
        UserDefaults.standard.set(token, forKey: "token")
        
        self.routeMain.onNext(true)
        self.loading.accept(false)
        
    }
    
    
}
