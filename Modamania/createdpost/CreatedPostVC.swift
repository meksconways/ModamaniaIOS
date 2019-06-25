//
//  CreatedPostVM.swift
//  Modamania
//
//  Created by macbook  on 25.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import UIKit

class CreatedPostVC: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gönderiler"
        //self.navigationController?.navigationBar.topItem?.title = "Gönderiler"
        self.tableView.register(ProfilePostCell.self, forCellReuseIdentifier: "cellid")
    }
    
    var postModel: [MyProfilePostModel]?{
        didSet{
             self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = postModel?.count{
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! ProfilePostCell
        if let model = postModel{
            cell.model = model[indexPath.row]
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
    
}
