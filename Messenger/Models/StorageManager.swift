//
//  StorageManager.swift
//  Messenger
//
//  Created by Dewa Prabawa on 01/09/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import FirebaseStorage

public enum StorageError:Error{
    case failedToUpload
    case failedToDownloadURL
}


class StorageManager {
    static var shared = StorageManager()
    
    private var storage = Storage.storage().reference()
    
    typealias uploadPictureCompletion = (Result<String, StorageError>) -> Void
    typealias downloadPictureCompletion = (Result<URL, StorageError>) -> Void

    
}


extension StorageManager {
    ///Upload picture/photo to firebase and return completion with URL to download
    
    public func uploadProfilePicture(with data: Data, and filename: String, completion: @escaping uploadPictureCompletion){
            
        storage.child("image/\(filename)").putData(data, metadata: nil){ [weak self] _, error in
            
            guard let strongSelf = self else {return}
            
            guard error == nil else {
                print("failed to upload image to firebase")
                completion(.failure(.failedToUpload))
                return
            }
            
            strongSelf.storage.child("image/\(filename)").downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    print("Failed to get download URL")
                    completion(.failure(.failedToDownloadURL))
                    return
                }
                
                let absoluteString = url.absoluteString
                print("downloaded url returned: \(absoluteString)")
                completion(.success(absoluteString))
            }
            
        }
    }
    
    /// Download URL helper to fetch image profile
    public func downloadURL(with path:String, completion:@escaping downloadPictureCompletion){
        let ref = storage.child(path)
        
        ref.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(.failedToDownloadURL))
                return
            }
            completion(.success(url))
        }
    }


}
