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
    
    private var chatViewsCollectionView: UICollectionView?
    
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
        startingListeningChat()
    }
    
    private func collectionviewSetups(){
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        chatViewsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        chatViewsCollectionView?.delegate = self
        chatViewsCollectionView?.dataSource = self
        chatViewsCollectionView?.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.identifier)
        chatViewsCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        chatViewsCollectionView?.backgroundColor = .systemBackground
        guard let chatViewCollectionView = chatViewsCollectionView else {
            return
        }
        
        view.addSubview(chatViewCollectionView)
        
        NSLayoutConstraint.activate([
            chatViewCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            chatViewCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatViewCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatViewCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    
    private func addSubviews(){
       view.addSubview(noChatLabel)
       collectionviewSetups()
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
                    print("failed fetch chats")
                    return
                }
                print("fetched: \(fetchedChat)")
                self?.chats = fetchedChat
                
                DispatchQueue.main.async {
                self?.chatViewsCollectionView?.reloadData()
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
        let vc = ChatToConversationViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = username
        navigationController?.pushViewController(vc, animated: true)
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


extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let chat = chats[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.identifier, for: indexPath) as! ChatCell
        cell.backgroundColor = .systemGreen
        cell.configure(with:chat)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let chat = chats[indexPath.row]
        let vc = ChatToConversationViewController(with: chat.otherUserEmail, id: chat.id)
        vc.title = chat.name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 70)
    }
    
    
}
