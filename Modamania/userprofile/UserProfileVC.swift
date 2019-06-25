//
//  UserProfileVC.swift
//  Modamania
//
//  Created by macbook  on 25.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import LGButton

class UserProfileVC: UIViewController,
UITableViewDelegate,
UITableViewDataSource{
    
    private let disposeBag = DisposeBag()
    private let viewModel: UserProfileVM
    private let refreshControl = UIRefreshControl()
    
    var imagePicker = UIImagePickerController()
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    init(userId:String) {
        self.viewModel = UserProfileVM(userId: userId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0{
            return 1
        }
        else{
            if let count = model?.post.count{
                return count
            }
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! UserProfileHeaderCell
            cell.selectionStyle = .none
            cell.profileVC = self
            if let modelX = model{
                cell.model = modelX
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! ProfilePostCell
        cell.selectionStyle = .none
        
        if let modelX = arrayModel{
            cell.model = modelX[indexPath.row]
        }
        
        return cell
        
    }
    
    
    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: CF.semiBold, size: 17)!]
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.middlePrimary
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        
        
    }
    
    lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let indicatorView = UIActivityIndicatorView(style: .gray)
    
    
    func setupLoadingView(){
        
        self.view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        self.loadingView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        indicatorView.startAnimating()
        indicatorView.hidesWhenStopped = true
        
        
        
    }
    
    func removeLoadingView(){
        
        if self.view.subviews.contains(loadingView){
            loadingView.removeFromSuperview()
        }
        
    }
    
    private var model: MyProfileUserModel?{
        didSet{
            self.tableView.reloadData()
        }
    }
    private var arrayModel: [MyProfilePostModel]?{
        didSet{
           self.tableView.reloadData()
        }
    }
    
    func observeVM(){
        
        viewModel.getPageLoading()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (loading) in
                if loading{
                    self.setupLoadingView()
                }else{
                    self.removeLoadingView()
                }
                
            }).disposed(by: disposeBag)
        
        viewModel.getProfileData()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                
               
                
                
                if self.refreshControl.isRefreshing{
                    self.refreshControl.endRefreshing()
                }
                
                self.navigationItem.title = model.username
                
                self.model = model
                
                let arr = model.post
                self.arrayModel = arr.reversed()
                self.tableView.reloadData()
                
            }).disposed(by: disposeBag)
        
        viewModel.getBtnLoading()
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: {(loading) in
//                let indexPath = IndexPath(row: 0, section: 0)
//                if let cell = self.tableView.cellForRow(at: indexPath) as? UserProfileHeaderCell{
//                    if loading{
//                        cell.followBtn.isLoading = true
//                        cell.followBtn.isUserInteractionEnabled = false
//                    }else{
//                        cell.followBtn.isLoading = false
//                        cell.followBtn.isUserInteractionEnabled = true
//                    }
//                }
                
                
                
            }).disposed(by: disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeVM()
        self.viewModel.fetchProfile()
        
        refreshControl.rx.controlEvent(UIControl.Event.valueChanged)
            .observeOn(MainScheduler.instance)
            .delay(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { (_) in
                self.viewModel.fetchProfile()
            }.disposed(by: disposeBag)
        
    }
    
    lazy var tableView: UITableView = {
        
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.white
        tv.register(UserProfileHeaderCell.self, forCellReuseIdentifier: "headerCell")
        tv.register(ProfilePostCell.self, forCellReuseIdentifier: "postCell")
        tv.separatorStyle = .singleLine
        tv.separatorInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        tv.backgroundColor = UIColor.white
        tv.delegate = self
        tv.dataSource = self
        tv.refreshControl = refreshControl
        return tv
        
    }()
    
    func followUser(tag: Int){
        
        if tag == 0{
            viewModel.followUser()
        }else if tag == 1{
            viewModel.unFollowUser()
        }
  
    }
    
    func navigateToPosts(){
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        let vc = CreatedPostVC()
        let arr = self.model?.post
        vc.postModel = arr?.reversed()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToFollowers(){
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        let vc = MyFollowersVC()
        vc.userModel = self.model?.followers
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToFollowing(){
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        let vc = MyFollowingVC()
        vc.userModel = self.model?.following
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}

class UserProfileHeaderCell: UITableViewCell {
    
    
    var model: MyProfileUserModel?{
        didSet{
            
            if let pImage = model?.userFolder{
                if pImage == "default.jpeg"{
                    profileImage.image = UIImage(named: "user")
                }else{
                    let imageURL = URL(string: pImage)
                    profileImage.kf.setImage(with: imageURL)
                }
            }
            nameSurname.text = model?.fullName
            username.text = model?.username
            
            followBtn.isEnabled = true
            followBtn.alpha = 1.0
            //followBtn.isUserInteractionEnabled = true
            
            followBtn.titleString = "Takip Et"
            followBtn.tag = 0
            if let followers = model?.followers{

                let userId = UserDefaults.standard.string(forKey: "user_id")
                //print(userId)
                for i in followers{
                    print(i)
                    
                    if i.userId == userId{
                        followBtn.titleString = "Takip Ediliyor"
                        followBtn.tag = 1
                    }
   
                }
                
            }
 
            
            if let followers = model?.followersCount{
                btnfollowers.setTitle("\(followers)", for: UIControl.State.normal)
            }
            if let following = model?.followingCount{
                btnfollowing.setTitle("\(following)", for: UIControl.State.normal)
            }
            if let post = model?.postCount{
                btnPost.setTitle("\(post)", for: UIControl.State.normal)
            }
            
            
        }
    }
    
    var profileVC: UserProfileVC?
    
    let mainView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let profileImage : UIImageView = {
        
        let profileimage = UIImageView()
        profileimage.translatesAutoresizingMaskIntoConstraints = false
        profileimage.contentMode = .scaleAspectFill
        profileimage.image = UIImage(named: "cat_music")
        return profileimage
        
    }()
    
    let nameSurname : UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Jane Black"
        label.font = UIFont(name: CF.bold, size: 20.0)
        //label.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        return label
        
    }()
    
    let username : UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "blackjane"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: CF.medium, size: 16.0)
        //label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
        label.textColor = UIColor(rgb: 0x545454)
        return label
    }()
    
    
    
    
    
    
    let btnfollowers : UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.textAlignment = .center
        btn.setTitle("112", for: UIControl.State.normal)
        btn.tintColor = UIColor(rgb: 0x212121)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.font = UIFont(name: CF.bold, size: 17.0)
        return btn
    }()
    
    let btnfollowing : UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.numberOfLines = 0
        btn.tintColor = UIColor(rgb: 0x212121)
        btn.titleLabel?.font = UIFont(name: CF.bold, size: 17.0)
        btn.setTitle("1124", for: UIControl.State.normal)
        
        return btn
    }()
    
    let btnPost : UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.numberOfLines = 0
        btn.tintColor = UIColor(rgb: 0x212121)
        btn.titleLabel?.textAlignment = .center
        btn.setTitle("1127", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont(name: CF.bold, size: 17.0)
        //btn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        return btn
    }()
    
    let bottomBtnStack : UIStackView = {
        
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 0
        view.axis = .horizontal
        
        return view
        
    }()
    
    
    let takipciLabel : UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "takipçi"
        label.textColor = UIColor(rgb: 0x797979)
        label.font = UIFont(name: CF.regular, size: 14.0)
        //label.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        return label
        
    }()
    
    let takipLabel : UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "takip"
        label.textColor = UIColor(rgb: 0x797979)
        label.font = UIFont(name: CF.regular, size: 14.0)
        return label
        
    }()
    
    let postLabel : UILabel = {
        
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "gönderi"
        label.textColor = UIColor(rgb: 0x797979)
        label.font = UIFont(name: CF.regular, size: 14.0)
        return label
        
    }()
    
    let bottomlblStack : UIStackView = {
        
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.distribution = .fillEqually
        view.spacing = 0
        view.axis = .horizontal
        
        return view
        
    }()
    
    let followBtn: LGButton = {
        let btn = LGButton()
        btn.fullyRoundedCorners = true
        btn.gradientStartColor = UIColor.priceG1
        btn.gradientEndColor = UIColor.priceG2
        btn.gradientRotation = 60
        btn.loadingColor = UIColor.white
        btn.titleFontName = CF.semiBold
        btn.titleFontSize = 14.0
        btn.titleColor = UIColor.white
        btn.borderWidth = 0
        btn.borderColor = UIColor.white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    func setupUI(){
        
        addSubview(mainView)
        mainView.addSubview(profileImage)
        mainView.addSubview(nameSurname)
        mainView.addSubview(username)
        mainView.addSubview(followBtn)
        
        mainView.addSubview(bottomBtnStack)
        bottomBtnStack.addArrangedSubview(btnPost)
        bottomBtnStack.addArrangedSubview(btnfollowers)
        bottomBtnStack.addArrangedSubview(btnfollowing)
        mainView.addSubview(bottomlblStack)
        bottomlblStack.addArrangedSubview(postLabel)
        bottomlblStack.addArrangedSubview(takipciLabel)
        bottomlblStack.addArrangedSubview(takipLabel)
        
        
        mainView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        
        profileImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.height.equalTo(140)
            make.width.equalTo(140)
        }
        
        profileImage.layer.borderWidth = 0
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = 70.0
        profileImage.clipsToBounds = true
        
        nameSurname.snp.makeConstraints { (make) in
            make.top.equalTo(profileImage.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        username.snp.makeConstraints { (make) in
            make.top.equalTo(nameSurname.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        followBtn.snp.makeConstraints { (make) in
            make.top.equalTo(username.snp.bottom).offset(16)
            make.height.equalTo(38)
            make.width.equalTo(140)
            make.centerX.equalToSuperview()
        }
        
        bottomBtnStack.snp.makeConstraints { (make) in
            make.top.equalTo(followBtn.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        bottomlblStack.snp.makeConstraints { (make) in
            make.top.equalTo(bottomBtnStack.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        
        
        followBtn.rx.controlEvent(.touchUpInside)
        .observeOn(MainScheduler.instance)
        .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { (_) in
                //self.followBtn.isLoading = true
                self.followBtn.isEnabled = false
                self.followBtn.alpha = 0.6
                //self.followBtn.isUserInteractionEnabled = false
                self.profileVC?.followUser(tag: self.followBtn.tag)
        }.disposed(by: disposeBag)
        
        btnPost.rx.tap.observeOn(MainScheduler.instance)
            .bind { (_) in
                self.profileVC?.navigateToPosts()
            }.disposed(by: disposeBag)
        
        btnfollowers.rx.tap.observeOn(MainScheduler.instance)
            .bind { (_) in
                self.profileVC?.navigateToFollowers()
            }.disposed(by: disposeBag)
        
        btnfollowing.rx.tap.observeOn(MainScheduler.instance)
            .bind { (_) in
                self.profileVC?.navigateToFollowing()
            }.disposed(by: disposeBag)
        
       
        
        
    }
    
    var controller: UserProfileVC?
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}


