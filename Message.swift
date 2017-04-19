//
//  Message.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/17/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation

/// A class representing a message.
class Message: Equatable {

    var uid: String
    var senderUID: String
    var recipientUID: String
    var timeStamp: Double
    var body: String
    
    /// A constructor for Message.
    ///
    /// - Parameters:
    ///   - uid: Unique identifier for reference.
    ///   - senderID: Unique identifier of sender for reference.
    ///   - recipientID: Unique identifier of recipient for reference.
    ///   - timeStamp: Time message is sent.
    ///   - body: Contents of message.
    init(uid: String, senderUID: String, recipientUID: String, timeStamp: Double, body: String) {
        self.uid = uid
        self.senderUID = senderUID
        self.recipientUID = recipientUID
        self.timeStamp = timeStamp
        self.body = body
    }
}

/// Determine if two messages are the same message.
///
/// - Parameters:
///   - lhs: Message a.
///   - rhs: Message b.
/// - Returns: The boolean value of the messages equivalance.
func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.uid == rhs.uid
}
