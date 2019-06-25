//
//  SignUpVC.swift
//  Modamania
//
//  Created by macbook  on 18.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxKeyboard

class SignUpVC: UIViewController,UITextFieldDelegate,UIScrollViewDelegate {

    private let disposeBag = DisposeBag()
    private let viewModel = SignUpVM()
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var usernameTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    
    
    @IBOutlet weak var btnSignUp: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: CF.semiBold, size: 17)!]
        self.title = "Kaydol"
        indicatorView.hidesWhenStopped = true
        
        self.hideKeyboardWhenTappedAround()
        setupUI()
        
        // keyboard listener
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [scrollView] keyboardVisibleHeight in
                scrollView?.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
        observeVM()
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func setupUI(){
        nameTf.clipsToBounds = true
        usernameTf.clipsToBounds = true
        passwordTf.clipsToBounds = true
        emailTf.clipsToBounds = true
        
        nameTf.tag = 0
        usernameTf.tag = 1
        passwordTf.tag = 2
        emailTf.tag = 3
        
        nameTf.layer.cornerRadius = 24.0
        usernameTf.layer.cornerRadius = 24.0
        passwordTf.layer.cornerRadius = 24.0
        emailTf.layer.cornerRadius = 24.0
        btnSignUp.layer.cornerRadius = 24.0
        
        nameTf.delegate = self
        usernameTf.delegate = self
        passwordTf.delegate = self
        emailTf.delegate = self
    }
    
    
    func observeVM(){
        
        viewModel.getLoading()
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (loading) in
                
                if loading{
                    self.indicatorView.isHidden = false
                    self.view.isUserInteractionEnabled = false
                    self.indicatorView.startAnimating()
                }else{
                    self.view.isUserInteractionEnabled = true
                    self.indicatorView.stopAnimating()
                }
                
            }).disposed(by: disposeBag)
        
        viewModel.getErrorMsg().observeOn(MainScheduler.instance)
            .subscribe(onNext: { (msg) in
                
                if let message = msg {
                    self.showAlert(message: message)
                }
                
            }).disposed(by: disposeBag)
        
        viewModel.getRouteMain().observeOn(MainScheduler.instance)
            .subscribe(onNext: { (route) in
                self.routeMain()
            }).disposed(by: disposeBag)
        
    }
    
    
    func routeMain(){
        self.present(MainVC(), animated: false, completion: nil)
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertController.Style.alert)
        let okBtn = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func clickSignUp(_ sender: Any) {
        
        let fullName = nameTf.text!
        let username = usernameTf.text!
        let password = passwordTf.text!
        let email = emailTf.text!
        
        if fullName.isEmpty{
            showAlert(message: "İsim Soyisim alanı boş olamaz!")
            return
        }
        
        if username.isEmpty{
            showAlert(message: "Kullanıcı Adı alanı boş olamaz!")
            return
        }
        if password.isEmpty{
            showAlert(message: "Parola alanı boş olamaz!")
            return
        }
        
        if password.count < 6 {
            showAlert(message: "Parola en az 6 karakterli olmalı!")
            return
        }
        
        if email.isEmpty{
            showAlert(message: "E Posta alanı boş olamaz!")
            return
        }
        
        
        viewModel.signUp(fullName: fullName, username: username, password: password, email: email)
        
    }
    
    
    @IBAction func clickLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
   

}
