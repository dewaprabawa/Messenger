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
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let noChatLabel: UILabel = {
        let label = UILabel()
        label.text = "No Chat!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewChat))
        addSubviews()
        fetchChat()
        tableviewSetups()
        setupviews()
    }
    
    private func setupviews(){
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc private func addNewChat(){
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.createNewChat(result: result)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    private func createNewChat(result: [String:String]){
        guard let username = result["username"], let email = result["email"] else { return }
        let vc = ChatToConversationViewController(with: email)
        vc.isNewConversation = true
        vc.title = username
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func tableviewSetups(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func addSubviews(){
       view.addSubview(tableView)
       view.addSubview(noChatLabel)
    }
    
    private func fetchChat(){
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.title = "Chat"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        checkWheterItLoggedIn()
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


extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "First Chat"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatToConversationViewController(with: "sda@gmail.com")
        navigationController?.pushViewController(vc, animated: true)
    }
}
