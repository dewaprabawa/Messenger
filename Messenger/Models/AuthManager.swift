//
//  AuthManager.swift
//  Messenger
//
//  Created by Dewa Prabawa on 30/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn


public enum errorDescription:Error{
    case emailAlreadyExisted
    case failedToInsertDataToDatabase
    case failedToAuth
}

public class AuthManager {
    static var shared = AuthManager()
    
    public typealias completionHandler = (Bool, errorDescription?)-> Void
    
    /*
     /// - Register Email, checking the existing email and and inserting to database
     */
    
    public func registerNewUser(username:String, email: String, password:String, completion:@escaping completionHandler ){
        
        ///- checking whether the email already exist
        DatabaseManager.shared.checkIsEmailExisted(with: email) { (isExist) in
            /// if no email register proceed to auth proccesss
            
            if !isExist {
                
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (authRes, error) in
                    guard authRes != nil, error == nil else{
                        completion(false, .failedToAuth)
                        return
                    }
                    
                    
                    ///persists the email with userdefaults
                    UserDefaults.standard.set(email, forKey: "email")
                    
                    DatabaseManager.shared.insertIntoDatabase(with: ChatAppUser(username: username, email: email)){(success) in
                        if success {
                            /// success store data in firebase
                            completion(true, nil)
                            return
                        }else{
                            /// failed store data in firebase
                            completion(false, .failedToInsertDataToDatabase)
                            return
                        }
                        
                    }
                }
            }else{
                completion(false, .emailAlreadyExisted)
            }
        }
    }
    
    
    /// Login user
    public func loginUser(email:String, password:String, completion:@escaping (Bool)-> Void){
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (authRes, error) in
            guard authRes != nil, error == nil else {
                completion(false)
                return
            }
            
            if let usermail = authRes?.user.email {
                let safeEmail = DatabaseManager.shared.safeEmail(safe:  usermail)
                UserDefaults.standard.set(safeEmail, forKey: "email")
            }
            completion(true)
        }
    }
    
    /// SignOutUser
    public func signOutUser(completion:@escaping (Bool)->Void){
        
        /// Log out facebook
        FBSDKLoginKit.LoginManager().logOut()
        
        ///Google sign out
        GIDSignIn.sharedInstance()?.signOut()
   
        
        do{
           try FirebaseAuth.Auth.auth().signOut()
       
            completion(true)
            return
        }catch{
            print("unable to log out")
            completion(false)
            return
        }
    }
}
