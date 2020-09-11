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
    public var isNewConversation = false
    
    init(with email:String){
        self.otherUserEmail = email
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
        
       return Sender(photoURL:"", senderId: email, displayName: "Joe Smith")
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

}

extension ChatToConversationViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = selfSender,
            let messageId = createMessageId() else {
            return
        }
        
        print("this is text:\(text)")
        
        //MARK:- Send message
        if isNewConversation{
            /// if new message create it in database
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewChat(with: otherUserEmail, other_user: self.title ?? "Users", firstMessage: message) { success in
                if success {
                    print("the message sent")
                }else{
                    print("th message failed sent")
                }
            }
            
            
        }else{
            /// if not then just append it in database
            print("this not new chat")
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
        return Sender(photoURL: "", senderId: "", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

}
