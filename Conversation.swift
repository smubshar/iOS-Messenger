//
//  Conversation.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/18/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation


/// A class for representing conversations.
class Conversation {
    
    var uid: String
    var sender: User
    var recipient: User
    var messages = [Message]()
    
    
    /// A constructor for Conversation
    ///
    /// - Parameters:
    ///   - uid: Unique identifier for reference.
    ///   - senderID: Unique identifier of sender for reference.
    ///   - recipientID: Unique identifier of recipient for reference.
    init(uid: String, sender: User, recipient: User) {
        self.uid = uid
        self.sender = sender
        self.recipient = recipient
    }
}
