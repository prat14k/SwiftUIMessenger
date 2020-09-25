//
//  MessageCellView.swift
//  SwiftUICombineDemo
//
//  Created by Prateek on 25/09/20.
//

import SwiftUI

struct MessageCellView: View {
    let message: Message
    let isPreviousMessageFromSameUser: Bool
    let isNextMessageFromSameUser: Bool

    var body: some View {
        VStack(spacing: 5) {
            if !isPreviousMessageFromSameUser {
                HStack {
                    if message.isOutgoingMessage {
                        Spacer()
                    }
                    Text(caption)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(message.isOutgoingMessage ? .trailing : .leading)
                    if !message.isOutgoingMessage {
                        Spacer()
                    }
                }
            }
            HStack {
                if message.isOutgoingMessage {
                    Spacer()
                }
                Text(message.text)
                    .font(.body)
                    .foregroundColor(message.isOutgoingMessage ? .white : .black)
                    .padding()
                    .background(messageBubbleView)
                if !message.isOutgoingMessage {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var messageBubbleView: some View {
        var corners = UIRectCorner()
        if message.isOutgoingMessage {
            corners.insert(.topLeft)
            corners.insert(.bottomLeft)
            if !isPreviousMessageFromSameUser {
                corners.insert(.topRight)
            }
            if !isNextMessageFromSameUser {
                corners.insert(.bottomRight)
            }
        } else {
            corners.insert(.topRight)
            corners.insert(.bottomRight)
            if !isPreviousMessageFromSameUser {
                corners.insert(.topLeft)
            }
            if !isNextMessageFromSameUser {
                corners.insert(.bottomLeft)
            }
        }
        return RoundCornerView(corners: corners)
                .fill(message.isOutgoingMessage ? Color.blue : Color(red: 0.85, green: 0.85, blue: 0.85))
    }

    private var caption: String {
        if message.isOutgoingMessage {
            return message.timeStamp
        } else {
            return message.userName + " - " + message.timeStamp
        }
    }
}
