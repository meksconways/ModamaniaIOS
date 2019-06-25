//
//  FeedVM.swift
//  Modamania
//
//  Created by macbook  on 21.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class FeedVM {
    
    private let feedData = PublishSubject<[MyFeedModel]>()
    private let loading = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()
    
    func getFeedData() -> PublishSubject<[MyFeedModel]>{
        return feedData
    }
    
    func getLoading() -> BehaviorRelay<Bool>{
        return loading
    }
    
    func fetchFeed(){
        
        ApiClient.getFeed().observeOn(MainScheduler.instance)
            .subscribe(onNext: { (arrModel) in
                
                if arrModel.first?.message != nil{
                    return
                }
                
                self.feedData.onNext(arrModel)
                self.loading.accept(false)
                
            }).disposed(by: disposeBag)
    }
    
    
    
    
}
