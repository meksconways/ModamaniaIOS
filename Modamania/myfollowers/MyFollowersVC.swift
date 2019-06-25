//
//  MyFollowersVC.swift
//  Modamania
//
//  Created by macbook  on 25.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import UIKit

class MyFollowersVC: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(FollowersCell.self, forCellReuseIdentifier: "cellid")
        self.title = "Takipçiler"
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

class FollowersCell: BaseTableViewCell{
    
    
    var model: MyProfileFollowersModel?{
        didSet{
            
            if let pImage = model?.userFolder{
                if pImage == "default.jpeg"{
                    profileImage.image = UIImage(named: "user")
                }else{
                    let imageURL = URL(string: pImage)!
                    profileImage.kf.setImage(with: imageURL)
                }
            }
            
            usernameLabel.text = model?.username
            
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        self.addSubview(profileImage)
        self.addSubview(usernameLabel)
        
        profileImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        
        usernameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(profileImage.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    lazy var profileImage: UIImageView = {
       let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 22.0
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var usernameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CF.semiBold, size: 16.0)
        label.textColor = UIColor.darkTextColor
        return label
    }()
    
}
