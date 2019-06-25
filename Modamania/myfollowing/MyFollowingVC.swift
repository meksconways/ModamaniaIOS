//
//  MyFollowingVC.swift
//  Modamania
//
//  Created by macbook  on 25.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import UIKit

class MyFollowingVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "cellid")
        self.title = "Takip Edilenler"
    }
    
    
    var userModel: [MyProfileFollowersModel]?{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! FollowersCell
        if let model = userModel?[indexPath.row]{
            cell.model = model
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = userModel?.count{
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userId = userModel?[indexPath.row].userId{
            self.navigateToUserProfile(userId: userId)
        }
    }
    
    
    func navigateToUserProfile(userId: String){
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        let myUD = UserDefaults.standard.string(forKey: "user_id")!
        if myUD == userId{
            self.navigationController?.pushViewController(ProfileVC(), animated: true)
        }else{
            self.navigationController?.pushViewController(UserProfileVC(userId: userId), animated: true)
        }
        
    }
    
}
