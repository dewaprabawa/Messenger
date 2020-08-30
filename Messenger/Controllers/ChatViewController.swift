//
//  ViewController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 28/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.title = "Chat"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
        let rightBarButton = UIBarButtonItem(title: "Sign out", style: .done, target: self, action: #selector(signOut))
        self.navigationItem.rightBarButtonItem = rightBarButton
        checkWheterItLoggedIn()

    }
    
    @objc private func signOut(){
        AuthManager.shared.signOutUser{(success) in
            DispatchQueue.main.async {
                if success {
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true, completion: nil)
                }else{
                /// error occurred
                fatalError("could not log out the user")
                }
                
            }
        }
        
        
    }
    
    private func checkWheterItLoggedIn(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false, completion: nil)
        }
    }
    
    
}

