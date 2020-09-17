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

//MARK: - load username in firebase
extension DatabaseManager {
    func getData(with path: String, completion: @escaping (Result<Any,Error>)-> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value) {snapshot in
            print(path)
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToDownloadCollection))
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
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentUsername = UserDefaults.standard.value(forKey: "name") as? String else {
                print("masih dsini!")
            return
        }
        
        print("check :\(currentUsername)")
        
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
            
            let recipient_newChatData: [String:Any] = [
                "id":chatID,
                "other_user_email":safeEmail,
                "name":currentUsername,
                "latest_message":[
                    "date":messageDate,
                    "message":message,
                    "is_read":false,
                ]
            ]
            
            /*
            Update chat for current other-email
            */
            self?.database.child("\(otherUserEmail)/chats").observeSingleEvent(of:.value, with: { [weak self] snapshot in
                if var chats = snapshot.value as? [[String:Any]]{
                    ///Appends
                    chats.append(recipient_newChatData)
                    self?.database.child("\(otherUserEmail)/chats").setValue(chats)
                }else{
                    ///Creates
                    self?.database.child("\(otherUserEmail)/chats").setValue([recipient_newChatData])
                }
            })
            
            /*
             Update chat for current user-email
             */
            
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
    public func sendMessages(to chatId:String,other_user name: String, otheremail:String, message:Message, completion:@escaping (Bool)-> Void){
    
        database.child("\(chatId)/messages").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessage = snapshot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            guard let currentEmailUser = UserDefaults.standard.value(forKey: "email") as? String else {
                       completion(false)
                       return
                   }
                   
                   let safeEmail = currentEmailUser.safeDatabaseKey()
                   
                   let messageDate = ChatToConversationViewController.dateFormater.string(from: message.sentDate)
                   var messageContent = ""
                   
                   switch message.kind {
                       
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
                       "id":message.messageId,
                       "type": message.kind.messageKindString,
                       "content": messageContent,
                       "date": messageDate,
                       "sender_email": safeEmail,
                       "is_read":false,
                       "name":name
                   ]
            
                    
            currentMessage.append(message)
            
            strongSelf.database.child("\(chatId)/messages").setValue(currentMessage) { (error, _) in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                
                ///Updating the latest user chat
                strongSelf.database.child("\(safeEmail)/chats").observeSingleEvent(of: .value) { (snapshot) in
                    guard var currentChat = snapshot.value as? [[String:Any]] else {
                        print("cannot add latest chats")
                        completion(false)
                        return
                    }
                    
                    
                    let updateChat:[String: Any] = [
                        "date": messageDate,
                        "is_read": false,
                        "message":messageContent
                    ]
                    
                    var position = 0
                    var lastest_message:[String:Any]?
                    
                    for chatDictionary in currentChat{
                        if let _chatId = chatDictionary["id"] as? String, _chatId == chatId {
                            lastest_message = chatDictionary
                            break
                        }
                        position += 1
                    }
                    lastest_message?["latest_message"] = updateChat
                    guard let final_chat = lastest_message else {
                        completion(false)
                        return
                    }
                    
                    currentChat[position] = final_chat
                    
                    strongSelf.database.child("\(safeEmail)/chats").setValue(currentChat) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        ///Updating other user chat
                        strongSelf.database.child("\(otheremail)/chats").observeSingleEvent(of: .value) { (snapshot) in
                        guard var currentChat = snapshot.value as? [[String:Any]] else {
                            print("cannot add latest chats")
                            completion(false)
                            return
                        }
                        
                        
                        let updateChat:[String: Any] = [
                            "date": messageDate,
                            "is_read": false,
                            "message":messageContent
                        ]
                        
                        var position = 0
                        var lastest_message:[String:Any]?
                        
                        for chatDictionary in currentChat{
                            if let _chatId = chatDictionary["id"] as? String, _chatId == chatId {
                                lastest_message = chatDictionary
                                break
                            }
                            position += 1
                        }
                        lastest_message?["latest_message"] = updateChat
                        guard let final_chat = lastest_message else {
                            completion(false)
                            return
                        }
                        
                        currentChat[position] = final_chat
                        
                        strongSelf.database.child("\(otheremail)/chats").setValue(currentChat) { (error, _) in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            ///Updating other user chat
                            
                            
                            completion(true)
                        }
                     
                    }
                    
                }
            }
            
        }
       
      }
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
