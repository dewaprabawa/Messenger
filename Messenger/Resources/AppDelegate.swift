//
//  AppDelegate.swift
//  Messenger
//
//  Created by Dewa Prabawa on 28/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//


import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
 
    func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    func application( _ app: UIApplication,
                      open url: URL,
                      options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    /// Sign in with google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("unable to sign with google \(error)")
            }
            return
        }
        
        guard let email = user.profile.email,
            let name = user.profile.name else {
                return
        }
        
        let safeEmail = email.safeDatabaseKey()
        DatabaseManager.shared.getData(with: safeEmail) { (result) in
            switch result {
            case .failure(let error):
                print("failed to download the snapshot :\(error)")
            case .success(let data):
                guard let data = data as? [String: Any],
                    let username = data["username"] as? String else {
                    return
                }
                print("check from app delegate: \(username)")
                ///persists the email & email with userdefaults
                UserDefaults.standard.set(username, forKey: "name")
            }
        }
        ///persists the email & email with userdefaults
        UserDefaults.standard.set(email, forKey: "email")
        
        
        guard let authentication = user.authentication else {
            print("missing auth object off of google user")
            return }
        
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        DatabaseManager.shared.checkIsEmailExisted(with: email) { (success) in
            if !success{
                
                DatabaseManager.shared.insertIntoDatabase(with: ChatAppUser(username: name, email: email)) { (completeToInsert) in
                    
                    if completeToInsert {
                        
                        if user.profile.hasImage {
                            guard let url = user.profile.imageURL(withDimension: 200) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with:  url) { (data, _, _) in
                                guard let data = data else { return }
                                
                                let filename = "\(email.safeDatabaseKey())_profile_picture.png"
                                StorageManager.shared.uploadProfilePicture(with: data, and: filename) { (result) in
                                    switch (result){
                                    case .success(let imageURL):
                                        UserDefaults.standard.set(imageURL, forKey: "profile_picture_url")
                                        print(imageURL)
                                    case .failure(let error):
                                        print("failed to download imageURL :\(error)")
                                        
                                    }
                                }
                            }.resume()
                            
                        }
                        
                        
                        FirebaseAuth.Auth.auth().signIn(with: credential) { (authRes, error) in
                            guard authRes != nil, error == nil else {
                                print("failed to log in with google credential")
                                return
                            }
                            
                            print("Succeed to log in with google")
                            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
                        }
                    }else{
                        print("failed inserting data to firebase")
                    }
                    
                }
            }else{
                FirebaseAuth.Auth.auth().signIn(with: credential) { (authRes, error) in
                    guard authRes != nil, error == nil else{
                        return
                    }
                    print("Succeed to log in with google")
                    NotificationCenter.default.post(name: .didLoginNotification, object: nil)
                }
            }
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("google user was disconnected")
    }
    
}

    
