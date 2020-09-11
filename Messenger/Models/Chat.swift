//
//  Chat.swift
//  Messenger
//
//  Created by Dewa Prabawa on 11/09/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

struct Chat {
    let id: String
    let latestMessage: LatestMessage
    let name:String
    let otherUserEmail:String
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
