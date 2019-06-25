//
//  MainVC.swift
//  Modamania
//
//  Created by macbook  on 18.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import UIKit

class MainVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.tintColor = UIColor.middlePrimary
        self.tabBar.isTranslucent = false
        
        let controller1 = FeedVC()
        controller1.tabBarItem.title = "Ana Sayfa"
        controller1.tabBarItem.titlePositionAdjustment = .init(horizontal: 0, vertical: -2)
        controller1.tabBarItem.image = UIImage(named: "home")
        
        let controller3 = NotificationVC()
        controller3.tabBarItem.title = "Bildirimler"
        controller3.tabBarItem.titlePositionAdjustment = .init(horizontal: 0, vertical: -2)
        controller3.tabBarItem.image = UIImage(named: "notification")
        
        let controller4 = ProfileVC()
        controller4.tabBarItem.title = "Profil"
        controller4.tabBarItem.titlePositionAdjustment = .init(horizontal: 0, vertical: -2)
        controller4.tabBarItem.image = UIImage(named: "profile")
        
        let controller2 = TrendingVC()
        controller2.tabBarItem.title = "Trendler"
        controller2.tabBarItem.titlePositionAdjustment = .init(horizontal: 0, vertical: -2)
        controller2.tabBarItem.image = UIImage(named: "trending")
        
        
        viewControllers = [
                           UINavigationController(rootViewController: controller1),
                           UINavigationController(rootViewController: controller2),
                           UINavigationController(rootViewController: controller3),
                           UINavigationController(rootViewController: controller4)
        ]
        
    }
    

  

}
