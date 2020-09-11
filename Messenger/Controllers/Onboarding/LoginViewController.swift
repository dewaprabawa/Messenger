//
//  LoginViewController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 28/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        return spinner
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    let stackView = UIStackView()
    
    lazy var messengerLogo: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: "messenger")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let messengerTextLogo: UILabel = {
        let lb = UILabel()
        lb.text = "Messenger"
        lb.textAlignment = .center
        lb.textColor = .black
        lb.font = UIFont.boldSystemFont(ofSize: 30)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let upperContainer: UIView = {
        let vw = UIView()
        vw.backgroundColor = .green
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    private let emailFeild: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textfield.leftViewMode = UITextField.ViewMode.always
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.placeholder = "Email Address..."
        return textfield
    }()
    
    private let passwordFeild: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.autocapitalizationType = .none
        textfield.isSelected = true
        textfield.autocorrectionType = .no
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textfield.leftViewMode = UITextField.ViewMode.always
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.placeholder = "Password..."
        return textfield
    }()
    
    private let createAccountIfDoesNotHave: UIButton = {
        let btn = UIButton(type:.system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.setTitle("Don't have an account ?", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.addTarget(self, action: #selector(registerNewUser), for: .touchUpInside)
        return btn
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("LOG IN", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return btn
    }()
    
    private let facebookBtn = FBLoginButton()
    
    private let googleBtn:GIDSignInButton = {
        var btn = GIDSignInButton()
        btn.style = .wide
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let facebookButtonContainer:UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.layer.cornerRadius = 10
        vw.layer.masksToBounds = true
        vw.backgroundColor = .systemBlue
        return vw
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    private var alertOberver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Login"
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.spacing = 10
        
        self.facebookBtn.translatesAutoresizingMaskIntoConstraints = false
        self.facebookBtn.delegate = self
        self.facebookBtn.permissions = ["email, public_profile"]
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: {[weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.dismiss(animated: true, completion: nil)
        })
        
        alertOberver = NotificationCenter.default.addObserver(forName: .didTapAlertNotification, object: nil, queue: .main, using: {[weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.actionController(with: "Woops", show: "The email already existed")
        })
        
        addSubviews()
        constraintSetups()
        emailFeild.delegate = self
        passwordFeild.delegate = self
        
        
    }
    
    private func addSubviews(){
        view.addSubview(scrollView)
        self.scrollView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(upperContainer)
        stackView.addArrangedSubview(messengerLogo)
        stackView.addArrangedSubview(messengerTextLogo)
        stackView.addArrangedSubview(emailFeild)
        stackView.addArrangedSubview(passwordFeild)
        stackView.addArrangedSubview(loginButton)
        facebookButtonContainer.addSubview(facebookBtn)
        stackView.addArrangedSubview(googleBtn)
        stackView.addArrangedSubview(facebookButtonContainer)
        stackView.addArrangedSubview(createAccountIfDoesNotHave)
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer )
        }
    }
    
    private func constraintSetups(){
        NSLayoutConstraint.activate([
            
            ///Constraint scroll view
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            ///Constraint Logo
            messengerLogo.heightAnchor.constraint(equalToConstant: 200),
            messengerLogo.widthAnchor.constraint(equalToConstant: 200),
            
            ///Constraint email Textfield
            emailFeild.heightAnchor.constraint(equalToConstant: 45),
            emailFeild.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            emailFeild.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20
            ),
            ///Constraint password Textfield
            passwordFeild.heightAnchor.constraint(equalToConstant: 45),
            passwordFeild.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            passwordFeild.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20
            ),
            ///Constraint login button
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            loginButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            
            ///Facebook Login Button
            facebookButtonContainer.heightAnchor.constraint(equalToConstant: 45),
            facebookButtonContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            facebookButtonContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            
            facebookBtn.topAnchor.constraint(equalTo: facebookButtonContainer.topAnchor),
            facebookBtn.bottomAnchor.constraint(equalTo: facebookButtonContainer.bottomAnchor),
            facebookBtn.leadingAnchor.constraint(equalTo: facebookButtonContainer.leadingAnchor),
            facebookBtn.trailingAnchor.constraint(equalTo: facebookButtonContainer.trailingAnchor),
            
            
            ///Google Login Button
            googleBtn.heightAnchor.constraint(equalToConstant: 45),
            googleBtn.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            googleBtn.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20),
            
            
            ///Constraint stack view
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            
            self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
            
        ])
        
        
    }
    
    
    @objc private func didTapLogin(){
        emailFeild.resignFirstResponder()
        passwordFeild.resignFirstResponder()
        
        guard let email = emailFeild.text, !email.isEmpty,
            let password = passwordFeild.text, !password.isEmpty, password.count >= 8 else {
                alertController()
                return
        }
        

        spinner.show(in: view)
        
        AuthManager.shared.loginUser(email: email, password: password) { (success) in
            if success {
                self.spinner.dismiss()
                self.dismiss(animated: true, completion: nil)
            }else{
                self.spinner.dismiss()
                self.actionController(with: "Sorry", show: "You have not registered yet!")
            }
        }
    }
    
    private func alertController(){
        let alertController = UIAlertController(title: "Hey!", message: "Please fill the required detail to Log in", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func actionController(with title: String, show message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func registerNewUser(){
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailFeild {
            passwordFeild.becomeFirstResponder()
        }else if textField == passwordFeild{
            didTapLogin()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        /// log out
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        ///Requesting user detail in facebook account
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email,name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start { (connection, result, error) in
            guard let result = result as? [String:Any],
                error == nil else {
                    return
            }
            
            guard let name = result["name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String:Any], let data = picture["data"] as? [String: Any], let url = data["url"] as? String, let validURL = URL(string: url) else {
                print("failed take name and email in facebook")
                return
            }
            
            ///persists the email with userdefaults
            UserDefaults.standard.set(email, forKey: "email")
            
    
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            DispatchQueue.main.async {
                self.spinner.show(in: self.view)
            }
            
            
            DatabaseManager.shared.checkIsEmailExisted(with: email) { (success) in
                if !success{
                    /// if the email not exist
                    
                    FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authRes, error in
                        guard let strongSelf = self else { return }
                        guard authRes != nil, error == nil else {
                            return
                        }
                        print("Succesfully logged user in")
                        strongSelf.spinner.dismiss()
                        strongSelf.dismiss(animated: true, completion: nil)
                    }
                    
                    DatabaseManager.shared.insertIntoDatabase(with: ChatAppUser(username: name, email: email)) { (success) in
                        
                        if success {
                        
                            URLSession.shared.dataTask(with: validURL) { (data, _, _) in
                               print("checking the url :\(validURL)")
                                
                                guard let data = data else { return }
                                
                                let filename = "\(email.safeDatabaseKey())_profile_picture.png"
                                
                                StorageManager.shared.uploadProfilePicture(with: data, and: filename) { (result) in
                                    switch (result){
                                    case .success(let imageURL):
                                        UserDefaults.standard.set(imageURL, forKey: "profile_picture_url")
                                        print(imageURL)
                                    case .failure(let error):
                                        print("failed to download imageURL :\(error)")
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self.spinner.dismiss()
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }.resume()
                            
                        }
                        
                    }
                }else{
                    /// if the email not exist
                    FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authRes, error in
                        guard let strongSelf = self else { return }
                        guard authRes != nil, error == nil else {
                            return
                        }
                        print("Succesfully logged user in")
                        strongSelf.spinner.dismiss()
                        strongSelf.dismiss(animated: true, completion: nil)
                    }
                    
                    
                }
                
                
            }
            
            
        }
    }
}
