//
//  LoginVC.swift
//  Modamania
//
//  Created by macbook  on 17.06.2019.
//  Copyright © 2019 meksconway. All rights reserved.
//

import Foundation
import UIKit
import RxKeyboard
import RxCocoa
import RxSwift
import Alamofire

class LoginVC: UIViewController,UIScrollViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    
    private let disposeBag = DisposeBag()
    private let viewModel = LoginVM()
    
    fileprivate func setupUI() {
        btnLogin.layer.cornerRadius = 24.0
        btnSignUp.layer.cornerRadius = 24.0
        usernameTxt.clipsToBounds = true
        passwordTxt.clipsToBounds = true
        usernameTxt.layer.cornerRadius = 24.0
        passwordTxt.layer.cornerRadius = 24.0
        usernameTxt.delegate = self
        passwordTxt.delegate = self
        usernameTxt.tag = 0
        passwordTxt.tag = 1
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        scrollView.delegate = self
        
        // keyboard listener
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [scrollView] keyboardVisibleHeight in
                scrollView?.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
        
        setupUI()
        observeVM()
        
        
    }
    
    func observeVM(){
        viewModel.getLoading()
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (loading) in
                if loading{
                    self.view.isUserInteractionEnabled = false
                    self.indicatorView.startAnimating()
                }else{
                    self.view.isUserInteractionEnabled = true
                    self.indicatorView.stopAnimating()
                    
                }
            }).disposed(by: disposeBag)
        
        viewModel.getLoginData().observeOn(MainScheduler.instance)
            .subscribe(onNext: { (model) in
                self.navigateToMain()
            }).disposed(by: disposeBag)
        
        viewModel.getErrorMsg()
        .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (msg) in
                
                if let message = msg{
                    self.showAlertDialog(msg: message)
                }
                
            }).disposed(by: disposeBag)
    }
    
    func showAlertDialog(msg: String){
        
        let alert = UIAlertController(title: "Oops!", message: msg, preferredStyle: UIAlertController.Style.alert)
        let p_action = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(p_action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func navigateToMain(){
        
        self.present(MainVC(), animated: false, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBAction func loginBtnClick(_ sender: Any) {
        
        //navigateToMain()
        
        let username = usernameTxt.text!
        let password = passwordTxt.text!
        
        
        
        viewModel.login(username: username, password: password)
        
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
