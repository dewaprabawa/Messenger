//
//  LoginViewController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 28/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

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
        btn.setTitle("LOG IN", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
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
    
    
    
    @objc private func didTapLogin(){
        emailFeild.resignFirstResponder()
        passwordFeild.resignFirstResponder()
        
        guard let email = emailFeild.text, !email.isEmpty,
            let password = passwordFeild.text, !password.isEmpty, password.count >= 8 else {
                alertController()
                return
        }
    }
    
    private func alertController(){
        let alertController = UIAlertController(title: "Hey!", message: "Please fill the required detail to Log in", preferredStyle: .actionSheet)
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
