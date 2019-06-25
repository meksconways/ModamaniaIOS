//
//  AddPostVC.swift
//  Modamania
//
//  Created by macbook  on 24.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import UIKit
import LGButton
import SPFakeBar
import RxKeyboard
import RxCocoa
import RxSwift
import CropViewController
import Alamofire

class AddPostVC: UIViewController,
UIImagePickerControllerDelegate,
CropViewControllerDelegate,
UINavigationControllerDelegate{
    
    
    let navBar = SPFakeBarView(style: .stork)
    private let disposeBag = DisposeBag()
    
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
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.cancelButtonTitle = "Vazgeç"
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.customAspectRatio = CGSize(width: 16, height: 9)
        present(cropViewController, animated: true, completion: nil)
    }
    
    
    // crop sonucu
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        //viewModel.setEventImageState(state: .selectedSmall)
        //eventImage.contentMode = .scaleAspectFill
        imageView.image = image
        
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
   
    
    
    fileprivate func setupNavBar() {
        self.view.backgroundColor = UIColor.white
        self.hideKeyboardWhenTappedAround()
        self.navBar.titleLabel.text = "Gönderi Oluştur"
        self.navBar.leftButton.setTitle("Vazgeç", for: .normal)
        self.navBar.leftButton.addTarget(self, action: #selector(self.dismissAction), for: .touchUpInside)
        self.navBar.elementsColor = UIColor.middlePrimary
        self.navBar.titleLabel.font = UIFont(name: CF.semiBold, size: 17.0)
        self.view.addSubview(self.navBar)
        imagePicker.delegate = self
    }
    
    fileprivate func setupKeyboard(){
        // keyboard listener
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [scrollView] keyboardVisibleHeight in
                scrollView.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
    }
    
    
    func setupListeners(){
        
        addPhotoBtn.rx.tap
        .observeOn(MainScheduler.instance)
        .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { (_) in
                self.pickPhoto()
        }.disposed(by: disposeBag)
        
        createPostBtn.rx.controlEvent(UIControl.Event.touchUpInside)
        .observeOn(MainScheduler.instance)
        .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .bind { (_) in
                self.createPost()
        }.disposed(by: disposeBag)
        
    }
    
    func createPost(){
        self.createPostBtn.isUserInteractionEnabled = false
        self.createPostBtn.isLoading = true
//        callsendImageAPI(param: ["description" : self.descriptionField.text!], arrImage: [self.imageView.image!], imageKey: "post_image", URlName: "https://modamania.herokuapp.com/api/createPost", controller: self,
//                         withblock: { (result) in
//            self.dismiss(animated: true, completion: nil)
//        })
     
        uploadPostImage(param: ["description" : self.descriptionField.text!], arrImage: [self.imageView.image!], imageKey: "post_image", URlName: "https://modamania.herokuapp.com/api/createPost")
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupKeyboard()
        setupUI()
        setupListeners()
        
        
    }
    
    @objc func dismissAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupUI(){
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(addPhotoBtn)
        containerView.addSubview(desLabel)
        containerView.addSubview(descriptionField)
        containerView.addSubview(createPostBtn)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(navBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().priority(.low)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        let arImageView = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 16/9, constant: 1)
        imageView.addConstraint(arImageView)
        
        addPhotoBtn.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(54)
        }
        
        desLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addPhotoBtn.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        descriptionField.snp.makeConstraints { (make) in
            make.top.equalTo(desLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(100)
        }
        
        createPostBtn.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionField.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(54)
            make.bottom.lessThanOrEqualToSuperview().offset(-44)
        }
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    lazy var containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
       let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.darkSmokeColor
        return iv
    }()
    
    let addPhotoBtn: UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.setTitle("Fotoğraf Ekle", for: UIControl.State.normal)
        btn.setImage(UIImage(named: "addPhoto"), for: UIControl.State.normal)
        btn.tintColor = UIColor.white
        btn.titleLabel?.font = UIFont(name: CF.semiBold, size: 16.0)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        btn.backgroundColor = UIColor.middlePrimary
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    lazy var desLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Açıklama"
        label.font = UIFont(name: CF.semiBold, size: 15.0)
        label.textColor = UIColor.darkTextColor
        return label
    }()
    
    lazy var descriptionField: UITextView = {
        let field = UITextView()
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 4.0
        field.font = UIFont(name: CF.regular, size: 14.0)
        field.tintColor = UIColor.middlePrimary
        field.layer.borderColor = UIColor.shimmerColor.cgColor
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let createPostBtn: LGButton = {
        let btn = LGButton()
        btn.fullyRoundedCorners = true
        btn.bgColor = UIColor.middlePrimary
        btn.loadingColor = UIColor.white
        btn.titleFontName = CF.bold
        btn.titleFontSize = 16.0
        btn.titleString = "Oluştur"
        btn.titleColor = UIColor.white
        btn.borderWidth = 0
        btn.borderColor = UIColor.white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    func uploadPostImage(param:[String: Any],arrImage:[UIImage],imageKey:String,URlName:String){
        
        let headers: HTTPHeaders
        headers = ["Content-Type": "multipart/form-data",
                   "Authorization":"Bearer "+UserDefaults.standard.string(forKey: "token")!
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            
            for img in arrImage {
                guard let imgData = img.jpegData(compressionQuality: 1) else { return }
                multipartFormData.append(imgData, withName: imageKey, fileName: "asdasd.jpeg", mimeType: "image/jpeg")
            }
            
            
        },
                  to: "https://modamania.herokuapp.com/api/createPost",
                  method: .post,
                  headers: headers)
            .response{ response in
                do{
                    
                    if let jsonData = response.data{
                        let parsedData = try JSONSerialization.jsonObject(with: jsonData) as! Dictionary<String, AnyObject>
                        print(parsedData)
                        
                        DispatchQueue.main.async {
                            // send notify
                            self.dismiss(animated: true, completion: nil)
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "listenCreatedPost"), object: nil)
                        }
                    }
                    
                }catch{
                    print("error message")
                }
                
        }
    }
    
}
    
public func callsendImageAPI(param:[String: Any],arrImage:[UIImage],imageKey:String,URlName:String,controller:UIViewController, withblock:@escaping (_ response: AnyObject?)->Void){
    print("burda!!0")
    let headers: HTTPHeaders
    headers = ["Content-Type": "multipart/form-data",
               "Authorization":"Bearer "+UserDefaults.standard.string(forKey: "token")!
    ]
    
    print("**headers:",headers)
    
    AF.upload(multipartFormData: { (multipartFormData) in
        print("burda!!upload içi")
        for (key, value) in param {
            multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
        }
        
        for img in arrImage {
            guard let imgData = img.jpegData(compressionQuality: 1) else { return }
            multipartFormData.append(imgData, withName: imageKey, fileName: "asdasd.jpeg", mimeType: "image/jpeg")
        }
        
        
    },
      to: "https://modamania.herokuapp.com/api/createPost",
      method: .post,
      headers: headers)
        .response{ response in
            print("***response: ",response)
            do{
                if let jsonData = response.data{
                    let parsedData = try JSONSerialization.jsonObject(with: jsonData) as! Dictionary<String, AnyObject>
                    print(parsedData)
                }
                
            }catch{
                print("error message")
            }
        
    }
}

