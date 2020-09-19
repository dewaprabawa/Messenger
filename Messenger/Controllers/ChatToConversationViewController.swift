//
//  ChatToConversationController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 01/09/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import JGProgressHUD

struct Message: MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}

extension MessageKind{
    var messageKindString:String{
        switch self {
        case .text(_):
            return "Text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender:SenderType {
   public var photoURL: String
   public var senderId: String
   public var displayName: String
}

class ChatToConversationViewController: MessagesViewController {

    public let otherUserEmail:String
    private let chatid: String?
    public var isNewConversation = false
    
    
    init(with email:String, id: String?){
        self.otherUserEmail = email
        self.chatid = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static var dateFormater: DateFormatter = {
      let formater = DateFormatter()
        formater.dateStyle = .medium
        formater.timeStyle = .long
        formater.locale = .current
        return formater
    }()
    
    private var messages = [Message]()
    
    private var selfSender: Sender?{
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        return Sender(photoURL:"", senderId: email.safeDatabaseKey(), displayName: "Joe Smith")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        // Do any additional setup after loading the view.
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
        
    }
    
    private func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        button.onTouchUpInside { [weak self](_) in
            self?.presentInputActionSheet()
        }
    }
    
    private func presentInputActionSheet(){
        let actionController = UIAlertController(title: "Attach Media", message: "What would you like to attach", preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputAction()
        }))
        
        actionController.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputAction()
        }))
        
        actionController.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputAction()
        }))
        
        actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionController, animated: true)
    }
    
    private func presentPhotoInputAction(){
        let actionController = UIAlertController(title: "Attach Photo", message: "What would you like to attach", preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .camera
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionController.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
           let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.present(picker, animated: true, completion: nil)
            picker.allowsEditing = true
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionController.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
    }
    
    private func presentVideoInputAction(){
        
    }
    
    private func presentAudioInputAction(){
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let chatId = chatid {
            listenForMessages(id: chatId, isScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id:String, isScrollToBottom:Bool){
        DatabaseManager.shared.getAllMessagesForChat(with: id) { [weak self] result in
            switch (result){
            case .failure(let error):
                print("error occured when download chat: ----\(error)")
            case .success(let chats):
                guard !chats.isEmpty else {
                    return
                }
                
                self?.messages = chats
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if isScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    
                }
            }
        }
    }
}

extension ChatToConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}

extension ChatToConversationViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = selfSender,
            let messageId = createMessageId() else {
            return
        }
  
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        
        //MARK:- Send message
        if isNewConversation{
            /// if new message create it in database
            DatabaseManager.shared.createNewChat(with: otherUserEmail, other_user: self.title ?? "Users", firstMessage: message) {[weak self] success in
                if success {
                    print("the message sent")
                    self?.isNewConversation = false
                }else{
                    print("the message failed sent")
                }
            }
            
            
        }else{
            
            guard let chatId = chatid else{
                return
            }
            /// if not then just append it in databas
            DatabaseManager.shared.sendMessages(to: chatId, other_user: self.title ?? "Unknown", otheremail: otherUserEmail, message: message) { (isSent) in
                print(isSent)
                if isSent {
                    print("the message sent")
                }else {
                    print("the message failed to sent")
                }
            }
        }
    }
    
    
    private func createMessageId() -> String?{
        //date, otherUserEmail, senderEmail
    
        let dateString = Self.dateFormater.string(from: Date())
        
        guard let currentEmailUser = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        
        let createdNewId = "\(otherUserEmail)_\(currentEmailUser.safeDatabaseKey())_\(dateString)_"
        return createdNewId
    }
}

extension ChatToConversationViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("the email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

}
