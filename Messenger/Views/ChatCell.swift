//
//  ChatCell.swift
//  Messenger
//
//  Created by Dewa Prabawa on 11/09/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import UIKit
import SDWebImage

class ChatCell: UITableViewCell {
    
    static var identifier = "ChatCell"
    
    private let userImageView:UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "person.circle")
        image.layer.cornerRadius = 25
        image.tintColor = .gray
        return image
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Users"
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello World"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    public func configure(with model: Chat){
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        
        let path = "\(model.otherUserEmail)_profile_picture.png"
        
        StorageManager.shared.downloadURL(with: path) { (result) in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                  self.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to download \(error)")
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            NSLayoutConstraint.activate([
            userImageView.heightAnchor.constraint(equalToConstant: 50),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor,constant: 10),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            userNameLabel.heightAnchor.constraint(equalToConstant: 25),
            userNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            
            userMessageLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 10),
            userMessageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            userMessageLabel.heightAnchor.constraint(equalToConstant: 25),
            userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
        ])
    }
    
    private func addSubviews(){
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
}
