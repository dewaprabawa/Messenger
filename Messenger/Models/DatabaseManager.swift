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
    
    var name = ""
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
            let value = dataSnapshot.value as? NSDictionary
           
            self.name = value?["username"] as? String ?? ""
            print("value from \(self.name)")
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
                ///Suceeded inserting to database
                 completion(true)
                 return
            }else{
                ///failed
                completion(false)
                return
            }
        }
    }
}

struct ChatAppUser{
    let username:String
    let email:String
}
