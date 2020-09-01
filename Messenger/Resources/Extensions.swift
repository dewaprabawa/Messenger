//
//  Extensions.swift
//  Messenger
//
//  Created by Dewa Prabawa on 30/08/20.
//  Copyright © 2020 Dewa Prabawa. All rights reserved.
//

import Foundation

extension String {
    func safeDatabaseKey() -> String {
        return self.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }
}

extension Notification.Name {
    static let didLoginNotification = Notification.Name("")
    static let didTapAlertNotification = Notification.Name("alert")
}
