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
import JGProgressHUD
import SDWebImage
import AVKit
import AVFoundation

struct Message: MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

extension MessageKind{
    var messageKindString:String{
        switch self {
        case .text(_):
            return "text"
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
    private let chatid: String?
    public var isNewConversation = false
    let spinner = JGProgressHUD(style: .extraLight)
    
    init(with email:String, id: String?){
        self.otherUserEmail = email
        self.chatid = id
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
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        return Sender(photoURL:"", senderId: email.safeDatabaseKey(), displayName: "Joe Smith")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
        
    }
    
    private func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        button.onTouchUpInside { [weak self](_) in
            self?.presentInputActionSheet()
        }
    }
    
    private func presentInputActionSheet(){
        
        let actionController = UIAlertController(title: "Attach Media", message: "What would you like to attach", preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputAction()
        }))
        
        actionController.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputAction()
        }))
        
        actionController.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            self?.presentAudioInputAction()
        }))
        
        actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionController, animated: true)
        
        
    }
    
    private func presentPhotoInputAction(){
        let actionController = UIAlertController(title: "Attach Photo", message: "What would you like to attach a Photo?", preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .camera
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionController.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.spinner.show(in:strongSelf.view)
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            strongSelf.spinner.dismiss()
            strongSelf.present(picker, animated: true, completion: nil)
            
        }))
        
        actionController.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
    
    private func presentVideoInputAction(){
        let actionController = UIAlertController(title: "attach Video", message: "What you like to attach a video", preferredStyle: .actionSheet)
        
        actionController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionController.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true, completion: nil)
        }))
        
        actionController.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
    
    private func presentAudioInputAction(){
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let chatId = chatid {
            listenForMessages(id: chatId, isScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id:String, isScrollToBottom:Bool){
        DatabaseManager.shared.getAllMessagesForChat(with: id) { [weak self] result in
            switch (result){
            case .failure(let error):
                print("error occured when download chat: ----\(error)")
            case .success(let chats):
                guard !chats.isEmpty else {
                    return
                }
                
                self?.messages = chats
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if isScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                   }
                }
            }
        }
    }
}

extension ChatToConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let createMessageId = createMessageId(),
            let messageId = chatid, let selfSender = selfSender,
            let name = self.title else {
            return
        }
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = selectedImage.pngData() {
            
            let filename = "photo_message_" + createMessageId.replacingOccurrences(of: " ", with: "-") + ".png"

            /// Upload and save image to firebase
            StorageManager.shared.uploadMessagePhoto(with: imageData, and: filename) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let urlString):
                    
                    guard let urlString = URL(string: urlString),
                        let image = UIImage(systemName: "photo")else{
                            return
                    }
                    
                    let media = Media(url:urlString, image: nil, placeholderImage: image, size: .zero)
                    
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessages(to: messageId, other_user: name, otheremail: strongSelf.otherUserEmail, message: message) { (isSent) in
                        if isSent {
                            print("the photo has sent")
                        }else{
                            print("the photo has falied  to sent")
                        }
                    }
                }
            }
            ///Upload and save video to firebase
        }else if let videoURL = info[.mediaURL] as? URL{
            
            let fileURL = "video_message_" + createMessageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            StorageManager.shared.uploadMessageVideo(with: videoURL, and: fileURL) { [weak self](result) in
                guard let strongSelf = self else {
                    return
                }
                
                switch result{
                case .failure(let error):
                    print(error)
                case .success(let stringURL):
                    guard let urlString = URL(string: stringURL), let image = UIImage(systemName: "play.circle") else {
                        return
                    }
                    
                    let media = Media(url: urlString, image: nil, placeholderImage: image, size: .zero)
                    
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                    
                    DatabaseManager.shared.sendMessages(to: messageId, other_user: name, otheremail: strongSelf.otherUserEmail, message: message) { (isSent) in
                        if isSent {
                            print("The video has sent")
                        }else{
                            print("the video has failed to sent")
                        }
                    }
                }
            }
            
        }
    }
}




extension ChatToConversationViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        guard let selfSender = self.selfSender else {
            return
        }
        
        guard let messageId = createMessageId() else {
            return
        }
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
    
        //MARK:- Send message
        if isNewConversation{
            /// if new message create it in database
            DatabaseManager.shared.createNewChat(with: otherUserEmail, other_user: self.title ?? "Users", firstMessage: message) {[weak self] success in
                if success {
                    print("the message sent")
                    self?.isNewConversation = false
                }else{
                    print("the message failed sent")
                }
            }
            
            
        }else{
            
            guard let chatId = chatid else {
                return
            }
            
            /// if not then just append it in databas
            DatabaseManager.shared.sendMessages(to: chatId, other_user: self.title ?? "Unknown", otheremail: otherUserEmail, message: message) { (isSent) in
                print(isSent)
                if isSent {
                    print("the message sent")
                }else {
                    print("the message failed to sent")
                }
            }
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
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch (message.kind){
        case.photo(let media):
            guard let image = media.url else {
                return
            }
            imageView.sd_setImage(with: image, completed: nil)
        default:
            break
        }
    }
}


extension ChatToConversationViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch (message.kind){
        case .photo(let photo):
            guard let url = photo.url else {
                return
            }
            let vc = PhotoViewerViewController(url: url)
            navigationController?.present(vc, animated: true, completion: nil)
        case .video(let video):
            guard let url = video.url else {
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: url)
            present(vc, animated: true, completion: nil)
        default:break
        }
    }
}
