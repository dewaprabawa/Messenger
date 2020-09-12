//
//  FirebaseManager.swift
//  Messenger
//
//  Created by Dewa Prabawa on 30/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import FirebaseDatabase

class DatabaseManager{
    static var shared = DatabaseManager()
    var database = Database.database().reference()
  
}

//MARK: - Database Account Manager
extension DatabaseManager {
    
    /// whether the email exist
    public func checkIsEmailExisted(with email: String, completion:@escaping (Bool)->Void){
        database.child(email.safeDatabaseKey()).observeSingleEvent(of: .value) { (dataSnapshot) in
            
            guard dataSnapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
     
            completion(true)
        }
    }
    
    /// inserts to database
    public func insertIntoDatabase(with data: ChatAppUser, completion:@escaping (Bool)->Void){
        let key = data.email.safeDatabaseKey()
        print("\(key) check from database manager")
        print(data.username)
        database.child(key).setValue([
            "username": data.username
        ]){error, _ in
            if error == nil {
                
                ///Creating users to database to make search, query
                
                /*
                 Users:[
                    [
                    "name": ....,
                     "safeEmail"....
                 ],
                 [
                 "name": ....,
                 "safeEmail"....
                 ]
                 ]
                 */
                
                self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                    
                    /// if the users child already existed already then just append new user
                    
                    if var collection = snapshot.value as? [[String:String]] {
                        ///Append to user dictionary
                        let newCollection = [
                            "username":data.username,
                            "email":data.email.safeDatabaseKey()
                        ]
                        
                        collection.append(newCollection)
                        
                        self.database.child("users").setValue(collection, withCompletionBlock: {error, _ in
                           guard error == nil else {
                            ///Failed creating Users child for store collection
                            completion(false)
                                return
                            }
                            completion(true)
                        })
                        
                    }else{
                        /// if the users child not exist the  make the array collections
                        
                        ///create to array dictionary
                        let newCollection:[[String:String]] = [
                              
                            ["username":data.username,
                             "email":data.email.safeDatabaseKey()
                            ]
                        ]
                        self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                            guard error == nil else {
                                ///Failed creating Users child for store collection
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    }
                }
      
        
            }else{
                ///failed
                completion(false)
                return
            }
        }
    }
}

//MARK:- Safe Email Method
extension DatabaseManager {
    func safeEmail(safe email: String) -> String {
        let safeEmail = email.safeDatabaseKey()
        return safeEmail
    }
}

//MARK: - Download the Users array of dictionary
extension DatabaseManager {
    func downloadUserCollection(completion:@escaping (Result<[[String:String]],DatabaseError>)->Void){
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String:String]] else {
                completion(.failure(.failedToDownloadCollection))
                return
            }
            
            completion(.success(value))
        }
    }
}

//MARK: - Sending Message Database/Conversations

extension DatabaseManager{
    
    /*
        "dfsdfdsfds" {
            "messages": [
                {
                    "id": String,
                    "type": text, photo, video,
                    "content": String,
                    "date": Date(),
                    "sender_email": String,
                    "isRead": true/false,
                }
            ]
        }
           conversaiton => [
              [
                  "conversation_id": "dfsdfdsfds"
                  "other_user_email":
                  "latest_message": => {
                    "date": Date()
                    "latest_message": "message"
                    "is_read": true/false
                  }
              ],
            ]
           */
    
    
    //Creates a new conversation with target user email and first user message sent
    public func createNewChat(with otherUserEmail: String, other_user name: String, firstMessage: Message, completion:@escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.shared.safeEmail(safe:currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var snapshot = snapshot.value as? [String:Any] else {
                print("user not found")
                completion(false)
                return
            }
            
            let messageDate = ChatToConversationViewController.dateFormater.string(from: firstMessage.sentDate)
            let messageId = firstMessage.messageId
            
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let chatID = "chat_\(messageId)"
            
            let newChatData: [String:Any] = [
                "id":chatID,
                "other_user_email":otherUserEmail,
                "name":name,
                "latest_message":[
                    "date":messageDate,
                    "message":message,
                    "is_read":false,
                ]
            ]
            
            if var chats = snapshot["chats"] as? [[String:Any]]{
                // if the chats existed, should append chat
                chats.append(newChatData)
                snapshot["chats"] = chats
                ref.setValue(chats) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreateChats(id: chatID, other_user: name, firstMessage: firstMessage, completion: completion)
                }
                
            }else{
                // the chat not existed, then creates one
                snapshot["chats"] = [
                    newChatData
                ]
                
                ref.setValue(snapshot) {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return }
                    self?.finishCreateChats(id: chatID, other_user: name, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    private func finishCreateChats(id:String, other_user name: String, firstMessage: Message, completion:@escaping (Bool) -> Void){
     
        
        guard let currentEmailUser = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let safeEmail = currentEmailUser.safeDatabaseKey()
        
        let messageDate = ChatToConversationViewController.dateFormater.string(from: firstMessage.sentDate)
        var messageContent = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            messageContent = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        
        let message:[String:Any] = [
            "id":firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": messageContent,
            "date": messageDate,
            "sender_email": safeEmail,
            "is_read":false,
            "name":name
        ]
        
        let value:[String:Any] = [
            "messages": [
              message
            ]
        ]
        
        database.child("\(id)").setValue(value) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    //Fetches and return all conversation/chat within the passed email
    public func getAllChat(with email: String, completion: @escaping (Result<[Chat],Error>)->Void){
        database.child("\(email)/chats").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToDownloadCollection))
                return
            }
            
            let chats:[Chat] = value.compactMap { dictionary in
                
                guard let id = dictionary["id"] as? String,
                      let other_user_email = dictionary["other_user_email"] as? String,
                      let name = dictionary["name"] as? String,
                      let latest_message = dictionary["latest_message"] as? [String:Any],
                      let sentDate = latest_message["date"] as? String,
                      let message = latest_message["message"] as? String,
                    let isRead = latest_message["is_read"] as? Bool else {
                        return nil
                }
         
                let latestMessageResponse = LatestMessage(date:sentDate, text: message, isRead: isRead)
                
                let composedChat = Chat(id: id, latestMessage:latestMessageResponse, name: name, otherUserEmail: other_user_email)
               
                return composedChat
            }
            
            completion(.success(chats))
        }
    }
    
    //get all message for a given chat
    public func getAllMessagesForChat(with id: String, completion:@escaping (Result<[Message],Error>)->Void){
          print("checking id from getAllMessagesForChat: \(id)")
        database.child("\(id)/messages").observe(.value) { (snapshot) in
            
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseError.failedToDownloadCollection))
                return
            }
            
            let messages:[Message] = value.compactMap { (dictionary) in
                guard let name = dictionary["name"] as? String,
//                    let isRead = dictionary["is_read"] as? Bool,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
//                    let type = dictionary["type"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatToConversationViewController.dateFormater.date(from: dateString) else {
                        return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender:sender, messageId: messageID, sentDate: date, kind: .text(content))
            }
            completion(.success(messages))
        }
        
    }
    
    //Send message with target chat and message
    public func sendMessages(to conversation:String, message:Message, completion:@escaping (Bool)-> Void){
        
    }
    
}


struct ChatAppUser{
    
    let username:String
    let email:String
    
    var profilePictureFileName:String{
        return "\(email.safeDatabaseKey())_profile_picture.png"
    }
}


//MARK: - Error

extension DatabaseManager {
    public enum DatabaseError:Error {
        case failedToDownloadCollection
    }
}
