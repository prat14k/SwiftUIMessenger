//
//  Message.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 24/09/20.
//

import Foundation

struct Message: Codable, Identifiable {

    let id: UUID
    let userName: String
    let text: String
    let timeStamp: String

    var isOutgoingMessage: Bool {
        userName == User.current.name
    }

    init(id: UUID = UUID(), userName: String, text: String, timeStamp: String) {
        self.id = id
        self.userName = userName
        self.text = text
        self.timeStamp = timeStamp
    }
}
