//
//  StorageManager.swift
//  Messenger
//
//  Created by Dewa Prabawa on 01/09/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import FirebaseStorage

class StorageManager {
    static var shared = StorageManager()
    
    private var storage = Storage.storage().reference()
    
    typealias uploadPictureCompletion = (Result<String, Error>) -> Void
    
}


extension StorageManager {
    ///Upload picture/photo to firebase and return completion with URL to download
    
    public func uploadProfilePicture(with data: Data, and filename: String, completion: @escaping uploadPictureCompletion){
            
        storage.child("image/\(filename)").putData(data, metadata: nil){ [weak self] _, error in
            
            guard let strongSelf = self else {return}
            
            guard error == nil else {
                print("failed to upload image to firebase")
                if let error = error {
                  completion(.failure(error))
                }
                return
            }
            
            strongSelf.storage.child("image/\(filename)").downloadURL { (url, error) in
                guard let url = url else {
                    print("Failed to get download URL")
                    if let error = error {
                        completion(.failure(error))
                    }
                    return
                }
                
                let absoluteString = url.absoluteString
                print("downloaded url returned: \(absoluteString)")
                completion(.success(absoluteString))
            }
            
        }
    }

}
