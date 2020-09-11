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
        
        ///Setups
         setupTableviews()
        
        if !UserDefaults.standard.bool(forKey: "setups"){
            UserDefaults.standard.set(true, forKey: "setups")
            UserDefaults.standard.set(nil, forKey: "email")
        }
    }

    
    private func setupTableviews(){
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.tableHeaderView = generateTableViewHeader()
    }
    
    private func generateTableViewHeader() -> UIView?{
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.shared.safeEmail(safe: email)
        
        let fileName = safeEmail + "_profile_picture.png"
        
        let path = "image/"+fileName
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        
        header.backgroundColor = .systemGreen
        
        let imageView = UIImageView(frame: CGRect(x: (header.frame.width-150)/2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 75.0
        imageView.layer.masksToBounds = true
        header.addSubview(imageView)
        
        StorageManager.shared.downloadURL(with: path) { (result) in
            switch(result){
            case .success(let url):
                self.getURLdownload(with: imageView, and: url)
            case .failure(let err):
                print(err)
            }
        }
        
        return header
    }
    
    
    private func getURLdownload(with image: UIImageView, and url:URL){
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            guard let data = data, err == nil else {
                return
            }
            DispatchQueue.main.async {
                let imageData = UIImage(data: data)
                image.image = imageData
            }
        }.resume()
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
                    
                    UserDefaults.standard.set(nil, forKey: "email")
                    
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    
                    let tabbar = self.tabBarController
                    tabbar?.selectedIndex = 0
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
