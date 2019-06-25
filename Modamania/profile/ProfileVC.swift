//
//  ProfileVC.swift
//  Modamania
//
//  Created by macbook  on 18.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CropViewController
import Alamofire

class ProfileVC: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CropViewControllerDelegate{
    
    
    
    
    private let disposeBag = DisposeBag()
    private let viewModel = ProfileVM()
    private let refreshControl = UIRefreshControl()
    
    var imagePicker = UIImagePickerController()
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    // present cropview
    func presentCropViewController(image: UIImage) {
        //Load an image
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        cropViewController.cancelButtonTitle = "Vazgeç"
        cropViewController.doneButtonTitle = "Seç"
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.customAspectRatio = CGSize(width: 1, height: 1)
        present(cropViewController, animated: true, completion: nil)
    }
    
    
    // crop sonucu
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        //viewModel.setEventImageState(state: .selectedSmall)
        //eventImage.contentMode = .scaleAspectFill
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! ProfileHeaderCell
        cell.profileImage.image = image
        
        self.uploadPostImage(arrImage: [image], imageKey: "profile_image",
                             URlName: "https://modamania.herokuapp.com/api/updateProfilePhoto")
   
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    
    
    // picker sonucu
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true,completion: nil)
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            
            self.presentCropViewController(image: img)
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! ProfileHeaderCell
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
        self.navigationItem.title = "Profil"
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.middlePrimary
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        imagePicker.delegate = self
   
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
                self.model = model
                let arr = model.post
                self.arrayModel = arr.reversed()
                
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
        tv.register(ProfileHeaderCell.self, forCellReuseIdentifier: "headerCell")
        tv.register(ProfilePostCell.self, forCellReuseIdentifier: "postCell")
        tv.separatorStyle = .singleLine
        tv.separatorInset = .init(top: 16, left: 0, bottom: 16, right: 0)
        tv.backgroundColor = UIColor.white
        tv.delegate = self
        tv.dataSource = self
        tv.refreshControl = refreshControl
        return tv
        
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.listenCreatedPost), name: NSNotification.Name(rawValue: "listenCreatedPost"), object: nil)
    }
    
    @objc func listenCreatedPost(){
        viewModel.fetchProfile()
    }
    
    func changeProfileImage(){
        pickPhoto()
        
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
    
    func uploadPostImage(arrImage:[UIImage],imageKey:String,URlName:String){
        
        let headers: HTTPHeaders
        headers = ["Content-Type": "multipart/form-data",
                   "Authorization":"Bearer "+UserDefaults.standard.string(forKey: "token")!
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in param {
//                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
//            }
//
            for img in arrImage {
                guard let imgData = img.jpegData(compressionQuality: 0.7) else { return }
                multipartFormData.append(imgData, withName: imageKey, fileName: "asdasd.jpeg", mimeType: "image/jpeg")
            }
            
            
        },
                  to: "https://modamania.herokuapp.com/api/updateProfilePhoto",
                  method: .post,
                  headers: headers)
            .response{ response in
                do{
                    
                    if let jsonData = response.data{
                        let parsedData = try JSONSerialization.jsonObject(with: jsonData) as! Dictionary<String, AnyObject>
                        print(parsedData)
                        
                        DispatchQueue.main.async {
                            // send notify
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "listenCreatedPost"), object: nil)
                        }
                    }
                    
                }catch{
                    print("error message")
                }
                
        }
    }
    
    

}
class ProfileHeaderCell: UITableViewCell {
    
    
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
            
            if let totalLike = model?.totalLike{
                peoplelikes.setTitle("\(totalLike)", for: UIControl.State.normal)
            }
            if let totalViewed = model?.totalViewed{
                viewed.setTitle("\(totalViewed)", for: UIControl.State.normal)
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
    
    var profileVC: ProfileVC?
    
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
    
    let peoplelikes : UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.textAlignment = .left
        let spacing:CGFloat = 5.0
        btn.tintColor = UIColor.middlePrimary
        btn.titleLabel?.font = UIFont(name: CF.regular, size: 16.0)
        btn.setTitle("8262", for: UIControl.State.normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing);
        btn.setImage(UIImage(named: "likefilled"), for: UIControl.State.normal)
        
        return btn
        
    }()
    
    let viewed : UIButton = {
        
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.textAlignment = .left
        let spacing:CGFloat = 5.0
        btn.titleLabel?.font = UIFont(name: CF.regular, size: 16.0)
        btn.tintColor = UIColor.middlePrimary
        btn.setTitle("11240", for: UIControl.State.normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing);
        btn.setImage(UIImage(named: "viewed"), for: UIControl.State.normal)
        
        return btn
        
    }()
    
    let btnstack : UIStackView = {
        
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 16.0
        view.axis = .horizontal
        
        return view
        
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
    
    
    
    func setupUI(){
        
        addSubview(mainView)
        mainView.addSubview(profileImage)
        mainView.addSubview(nameSurname)
        mainView.addSubview(username)
        mainView.addSubview(btnstack)
        btnstack.addArrangedSubview(peoplelikes)
        btnstack.addArrangedSubview(viewed)
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
        
        btnstack.snp.makeConstraints { (make) in
            make.top.equalTo(username.snp.bottom).offset(16)
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
        }
        
        bottomBtnStack.snp.makeConstraints { (make) in
            make.top.equalTo(btnstack.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        bottomlblStack.snp.makeConstraints { (make) in
            make.top.equalTo(bottomBtnStack.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }

        profileImage.addTapGestureRecognizer {
            self.profileVC?.changeProfileImage()
        }
        
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
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}

class ProfilePostCell: BaseTableViewCell{
    
    var model: MyProfilePostModel?{
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
        
        
    }
    
}

extension UIView {
    
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
}
