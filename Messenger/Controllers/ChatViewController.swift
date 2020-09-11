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
    
    private var chats = [Chat]()
    
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
        startingListeningChat()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
    }
    
    private func setupviews(){
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func startingListeningChat(){
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.shared.safeEmail(safe: currentUserEmail)
        
        DatabaseManager.shared.getAllChat(with: safeEmail) { [weak self] result in
            switch (result){
            case.success(let fetchedChat):
                guard !fetchedChat.isEmpty else {
                    return
                }
                print("fetched:\(fetchedChat)")
                self?.chats = fetchedChat
                
                DispatchQueue.main.async {
                
                    self?.tableView.reloadData()
                }
                
                case.failure(let error):
                print("failed fetch the chat...\(error)")
            }
        }
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
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
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
        chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        tableView.rowHeight = 60
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as! ChatCell
        cell.configure(with:chat)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = chats[indexPath.row]
        let vc = ChatToConversationViewController(with: chat.otherUserEmail)
        vc.title = chat.name
        navigationController?.pushViewController(vc, animated: true)
    }
}
