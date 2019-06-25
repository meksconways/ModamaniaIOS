//
//  FeedVC.swift
//  Modamania
//
//  Created by macbook  on 18.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Kingfisher
import LGButton
import SPStorkController

class FeedVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    private let cellId = "cellid"
    private let disposeBag = DisposeBag()
    private let viewModel = FeedVM()
    
    private let refreshControl = UIRefreshControl()
    
    private var model: [MyFeedModel] = []{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
       let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.refreshControl = refreshControl
        return tv
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Noteworthy-Bold", size: 20)!]
    }
    
    fileprivate func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Noteworthy-Bold", size: 20)!]
        self.navigationItem.title = "Modamania"
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.addSubview(tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        self.tableView.register(FeedCell.self, forCellReuseIdentifier: cellId)
        
        self.refreshControl.rx.controlEvent(UIControl.Event.valueChanged)
        .observeOn(MainScheduler.instance)
            .delay(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { (_) in
                self.viewModel.fetchFeed()
        }.disposed(by: disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        viewModel.fetchFeed()
        observeVM()
        setupFAB()
        
        fabBtn.rx.controlEvent(UIControl.Event.touchUpInside)
        .observeOn(MainScheduler.instance)
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { (_) in
                self.navigateToCreatePost()
        }.disposed(by: disposeBag)
        
        
    }
    
    func navigateToCreatePost(){
        self.presentAsStork(AddPostVC())
        
    }
    
    let fabBtn: LGButton = {
        let btn = LGButton()
        btn.fullyRoundedCorners = true
        btn.bgColor = UIColor.middlePrimary
        btn.borderWidth = 0
        btn.borderColor = UIColor.white
        btn.leftImageColor = UIColor.white
        btn.leftImageWidth = 42.0
        btn.leftImageHeight = 42.0
        btn.leftImageColor = UIColor.white
        btn.leftImageSrc = UIImage(named: "plus")
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.listenCreatedPost), name: NSNotification.Name(rawValue: "listenCreatedPost"), object: nil)
    }
    
    func setupFAB(){
        self.view.addSubview(fabBtn)
        fabBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(54)
            make.width.equalTo(54)
        }
    }
    
    lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
       
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
        
    }()
    
    func setLoadingPage(){
        self.view.addSubview(loadingView)
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        loadingView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func removeLoadingView(){
        loadingView.removeFromSuperview()
    }
 
    @objc func listenCreatedPost(){
        viewModel.fetchFeed()
    }
    
    
    func observeVM(){
        
        viewModel.getFeedData()
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (arrModel) in
                
                if self.refreshControl.isRefreshing{
                    self.refreshControl.endRefreshing()
                }
                
                self.model = arrModel
                
            }).disposed(by: disposeBag)
        
        viewModel.getLoading().observeOn(MainScheduler.instance)
            .subscribe(onNext: { (loading) in
                
                if loading{
                    
                    self.setLoadingPage()
                }else{
                    
                    self.removeLoadingView()
                }
                
            }).disposed(by: disposeBag)
        
        
    }

    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func navigateToUserProfile(userId: String){
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        if userId == UserDefaults.standard.string(forKey: "user_id"){
            self.navigationController?.pushViewController(ProfileVC(), animated: true)
        }else{
            self.navigationController?.pushViewController(UserProfileVC(userId: userId), animated: true)
        }
        
        
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FeedCell
        cell.selectionStyle = .none
        cell.feedVC = self
        cell.model = model[indexPath.row].posts
        
        
        return cell
    }
    
    func likePost(){
        
    }

}



class FeedCell: BaseTableViewCell{
    
    
    var model: FeedPostModel?{
        didSet{
            
            if let p_Image = model?.owner.userFolder{
                if p_Image == "default.jpeg"{
                    profileImage.image = UIImage(named: "user")
                }else{
                    let imageURL = URL(string: p_Image)!
                    profileImage.kf.setImage(with: imageURL)
                }
            }
       
            usernameLabel.text = model?.owner.username

            postImage.kf.setImage(with: URL(string: model!.postImage))
            descriptionLabel.text = model?.description
            
            likeBtn.setTitle(String(describing: model!.likeCount), for: UIControl.State.normal)
            commentBtn.setTitle(String(describing: model!.commentCount), for: UIControl.State.normal)
            viewedBtn.setTitle(String(describing: model!.viewedCount), for: UIControl.State.normal)
            
            //dateLabel.text = model?.createdDate
            
            if let starting_on = model?.createdDate{
                let endIndex = starting_on.index(starting_on.endIndex, offsetBy: -6)
                let trun = starting_on[...endIndex]
                let inputFormatter = DateFormatter()
                inputFormatter.locale = Locale(identifier: "tr_TR")
                inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" //2019-06-23T12:14:56.542Z
                guard let showDate = inputFormatter.date(from: String(trun))else{return}
                inputFormatter.dateFormat = "dd MMMM EEEE"
                let resultString = inputFormatter.string(from: showDate)
                dateLabel.text = resultString
            }
           
        }
    }
    
    var feedVC: FeedVC?
    
    func likePost(){
        //feedVC?.tableView.beginUpdates()
        //model?.changeLike()
        //feedVC?.tableView.endUpdates()
        
 
    }
    
    override func setupListeners() {
        super.setupListeners()
        
        likeItBtn.rx.controlEvent(UIControl.Event.touchUpInside)
        .observeOn(MainScheduler.instance)
        .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { (_) in
                self.likePost()
        }.disposed(by: disposeBag)
        
        addCollBtn.rx.tap.observeOn(MainScheduler.instance)
            .bind(onNext:{ (_) in
                //self.model?.changeColl()
            })
        .disposed(by: disposeBag)
    }
    
    
    
    lazy var profileImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.smokeWhite
        iv.layer.cornerRadius = 27
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "cat_music")
        return iv
    }()
    
    lazy var stackView: UIStackView = {
       let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = UIStackView.Distribution.fill
        sv.axis = .vertical
        sv.alignment = UIStackView.Alignment.fill
        sv.spacing = 0
        return sv
    }()
    
    lazy var usernameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "beriloyy"
        label.font = UIFont(name: CF.bold, size: 16.0)
        label.textColor = UIColor.middleDarkColor
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "olmadı"
        label.font = UIFont(name: CF.regular, size: 14.0)
        label.textColor = UIColor.lightTextColor
        return label
    }()
    
    lazy var postImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.smokeWhite
        iv.contentMode = UIView.ContentMode.scaleAspectFill
        iv.layer.cornerRadius = 8.0
        return iv
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bugün sizlere çok güzel bir anımdan bahsetmek istiyorum #pazartesi"
        label.numberOfLines = 0
        label.font = UIFont(name: CF.medium, size: 16.0)
        label.textColor = UIColor.middleDarkColor
        return label
    }()
    
    
    lazy var likeBtn: UIButton = {
      let btn = UIButton(type: .roundedRect)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "likefilled"), for: UIControl.State.normal)
        btn.setTitle("4", for: UIControl.State.normal)
        btn.backgroundColor = UIColor.clear
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        btn.tintColor = UIColor.lightTextColor
        return btn
    }()
    
    lazy var commentBtn: UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "comment"), for: UIControl.State.normal)
        btn.setTitle("6", for: UIControl.State.normal)
        btn.backgroundColor = UIColor.clear
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        btn.tintColor = UIColor.lightTextColor
        return btn
    }()
    
    lazy var viewedBtn: UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "viewed"), for: UIControl.State.normal)
        btn.setTitle("20", for: UIControl.State.normal)
        btn.backgroundColor = UIColor.clear
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        btn.tintColor = UIColor.lightTextColor
        return btn
    }()
    
    lazy var likeItBtn: UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "likeempty"), for: UIControl.State.normal)
        btn.backgroundColor = UIColor.clear
        btn.tintColor = UIColor.middlePrimary
        return btn
    }()
    
    lazy var addCollBtn: UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "addcoll"), for: UIControl.State.normal)
        btn.backgroundColor = UIColor.clear
        btn.tintColor = UIColor.middlePrimary
        return btn
    }()
    
    lazy var rightBtnstackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = UIStackView.Distribution.fillEqually
        sv.axis = .horizontal
        sv.alignment = UIStackView.Alignment.lastBaseline
        sv.spacing = 16
        return sv
    }()
    
    lazy var leftBtnstackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = UIStackView.Distribution.fillProportionally
        sv.axis = .horizontal
        sv.alignment = UIStackView.Alignment.firstBaseline
        sv.spacing = 16
        return sv
    }()
    
    
    override func setupUI() {
        super.setupUI()
        addSubview(profileImage)
        addSubview(stackView)
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(dateLabel)
        addSubview(descriptionLabel)
        addSubview(postImage)
        addSubview(leftBtnstackView)
        leftBtnstackView.addArrangedSubview(likeBtn)
        leftBtnstackView.addArrangedSubview(commentBtn)
        leftBtnstackView.addArrangedSubview(viewedBtn)
        addSubview(rightBtnstackView)
        rightBtnstackView.addArrangedSubview(likeItBtn)
        rightBtnstackView.addArrangedSubview(addCollBtn)
        
        profileImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(54)
            make.width.equalTo(54)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(profileImage.snp.centerY)
            make.left.equalTo(profileImage.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImage.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        postImage.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        let aspectRatio = NSLayoutConstraint(item: postImage, attribute: .width, relatedBy: .equal, toItem: postImage, attribute: .height, multiplier: 16/9, constant: 1)
        postImage.addConstraint(aspectRatio)
        
        leftBtnstackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.top.equalTo(postImage.snp.bottom).offset(16)
            
        }
        
        rightBtnstackView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.top.equalTo(postImage.snp.bottom).offset(16)
        }
        
        profileImage.addTapGestureRecognizer {
            
            
            if let userId = self.model?.owner.userId{
                self.feedVC?.navigateToUserProfile(userId: userId)
            }
            
        }
        
        usernameLabel.addTapGestureRecognizer {
            if let userId = self.model?.owner.userId{
                self.feedVC?.navigateToUserProfile(userId: userId)
            }
        }
        
        
        
        
    }
    
    
    
}

class BaseTableViewCell: UITableViewCell{
    
    
    let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupListeners()
    }
    
    
    
    func setupListeners() {
        
    }
    
    func setupUI(){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
