//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 28/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Do any additional setup after loading the view.
        let rightBarButton = UIBarButtonItem(title: "Sign out", style: .done, target: self, action: #selector(alertLogOutController))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        setupTableviews()
    }
    
    private func setupTableviews(){
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func alertLogOutController(){
        let controller = UIAlertController(title: "Sign out", message: "Do you really want to log out?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: {_ in
            self.signOut()
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
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
    
}




extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
}
