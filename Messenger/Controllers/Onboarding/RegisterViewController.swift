//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 28/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    let stackView = UIStackView()
    
    private let ProfilePicture: UIButton = {
        let btn = UIButton(type: .system)
        btn.setBackgroundImage(UIImage(systemName: "person"), for: .normal)
        btn.tintColor = .darkGray
        btn.setTitleColor(.white, for: .normal)
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(didTapChangeProfile), for: .touchUpInside)
        return btn
    }()
    
    let messengerTextLogo: UILabel = {
        let lb = UILabel()
        lb.text = "Messenger"
        lb.textAlignment = .center
        lb.textColor = .black
        lb.font = UIFont.boldSystemFont(ofSize: 30)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    let upperContainer: UIView = {
        let vw = UIView()
        vw.backgroundColor = .green
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    ///Email TextField
    private let emailFeild: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.placeholder = "  Email Address..."
        return textfield
    }()
    
    ///Username TextField
    private let usernameFeild: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.placeholder = "  Username..."
        return textfield
    }()
    ///Password TextField
    private let passwordFeild: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.autocapitalizationType = .none
        textfield.isSelected = true
        textfield.autocorrectionType = .no
        textfield.layer.cornerRadius = 12
        textfield.layer.borderWidth = 1
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textfield.layer.borderColor = UIColor.lightGray.cgColor
        textfield.placeholder = "  Password..."
        return textfield
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("REGISTER", for: .normal)
        btn.backgroundColor = .systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Login"
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let rightRegisterButton = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(registerNewUser))
        navigationItem.rightBarButtonItem = rightRegisterButton
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.spacing = 10

        
        addSubviews()
        constraintSetups()
        
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UIGestureRecognizer(target: self, action: #selector(didTapChangeProfile))
        ProfilePicture.addGestureRecognizer(gesture)
        
        emailFeild.delegate = self
        passwordFeild.delegate = self
        
    }
    
    @objc private func didTapChangeProfile(){
        print("change profile call")
    }
    
    private func addSubviews(){
        view.addSubview(scrollView)
        self.scrollView.addSubview(self.stackView)
        self.stackView.addArrangedSubview(upperContainer)
        stackView.addArrangedSubview(ProfilePicture)
        stackView.addArrangedSubview(messengerTextLogo)
        stackView.addArrangedSubview(usernameFeild)
        stackView.addArrangedSubview(emailFeild)
        stackView.addArrangedSubview(passwordFeild)
        stackView.addArrangedSubview(loginButton)
    }
    
    private func constraintSetups(){
        NSLayoutConstraint.activate([
            
            ///Constraint scroll view
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            ///Constraint Logo
            ProfilePicture.heightAnchor.constraint(equalToConstant: 100),
            ProfilePicture.widthAnchor.constraint(equalToConstant: 100),
            ///Constrain Username Textfield
            usernameFeild.heightAnchor.constraint(equalToConstant: 45),
            usernameFeild.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            usernameFeild.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20
            ),
            ///Constraint email Textfield
            emailFeild.heightAnchor.constraint(equalToConstant: 45),
            emailFeild.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            emailFeild.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20
            ),
            ///Constraint password Textfield
            passwordFeild.heightAnchor.constraint(equalToConstant: 45),
            passwordFeild.heightAnchor.constraint(equalToConstant: 45),
            passwordFeild.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            passwordFeild.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20
            ),
            ///Constraint login button
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            loginButton.heightAnchor.constraint(equalToConstant: 45),
            loginButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor,constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -20
            ),
            
            ///Constraint stack view
            self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            
            self.stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
            
        ])
        
        
    }
    
    @objc private func didTapRegister(){
        usernameFeild.resignFirstResponder()
        emailFeild.resignFirstResponder()
        passwordFeild.resignFirstResponder()
        
        guard let username = usernameFeild.text,!username.isEmpty, let email = emailFeild.text, !email.isEmpty,
            let password = passwordFeild.text, !password.isEmpty, password.count >= 8 else {
                alertController()
                return
        }
    }
    
    private func alertController(){
        let alertController = UIAlertController(title: "Hey!", message: "Please fill the required detail to Register", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func registerNewUser(){
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameFeild {
            emailFeild.becomeFirstResponder()
        }else if textField == emailFeild {
            passwordFeild.becomeFirstResponder()
        }else if textField == passwordFeild {
            didTapRegister()
        }
        return true
    }
}


