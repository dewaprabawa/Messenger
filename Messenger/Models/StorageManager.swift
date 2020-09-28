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
    
    typealias uploadCompletion = (Result<String, StorageError>) -> Void
    typealias downloadCompletion = (Result<URL, StorageError>) -> Void

    
}


extension StorageManager {
    ///Upload picture/photo to firebase and return completion with URL to download
    
    public func uploadProfilePicture(with data: Data, and filename: String, completion: @escaping uploadCompletion){
            
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
    
    ///Upload photo in message chat to send to other users
    public func uploadMessagePhoto(with data: Data, and filename: String, completion: @escaping uploadCompletion){
        storage.child("message_image/\(filename)").putData(data, metadata: nil) { (_, error) in
            guard error == nil else{
                print("Failed to upload the photo to send message")
                completion(.failure(.failedToUpload))
                return
            }
            self.storage.child("message_image/\(filename)").downloadURL { (downloadedURL, error) in
                guard error == nil, let url = downloadedURL else {
                    completion(.failure(.failedToDownloadURL))
                    print("failed to download url form firebase")
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    ///upload video in message chat to send to other users
    public func uploadMessageVideo(with fileURL: URL, and filename: String, completion: @escaping uploadCompletion){
        storage.child("video_file/\(filename)").putFile(from: fileURL, metadata: nil) { (_, error) in
            guard error == nil else {
                completion(.failure(.failedToUpload))
                print("Failed to upload video to firebase")
                return
            }
            
            self.storage.child("video_file/\(filename)").downloadURL { (downloadedURL, erro) in
                guard error == nil, let url = downloadedURL else {
                    completion(.failure(.failedToDownloadURL))
                    print("failed to download url from firebase")
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            }
        }
    }
    
    /// Download URL helper to fetch image profile
    public func downloadURL(with path:String, completion:@escaping downloadCompletion){
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
