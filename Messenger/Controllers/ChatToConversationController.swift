//
//  ChatToConversationController.swift
//  Messenger
//
//  Created by Dewa Prabawa on 01/09/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender:SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatToConversationController: MessagesViewController {

    
    private var messages = [Message]()
    private let selfSender = Sender(photoURL:"", senderId: "1", displayName: "Joe Smith")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Dewa Prabawa"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        // Do any additional setup after loading the view.
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello dude, how is it going?")))
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Not too good bro!")))
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("I am busy learning IOS Development, well I hope master it soon!")))


        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

extension ChatToConversationController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
