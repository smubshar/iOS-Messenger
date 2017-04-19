//
//  User.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/16/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation

/// A class for representing the users information
class User: NSObject {
    
    var uid: String
    var email: String
    var contacts: [String]
    
    /// Constructor for User.
    ///
    /// - Parameters:
    ///   - uid: Unique identifier for reference.
    ///   - email: Email address.
    ///   - contacts: Set of other users.
    init(uid: String, email: String, contacts: [String]) {
        self.email = email
        self.contacts = contacts
        self.uid = uid
    }
    
    /// Constructor for User.
    ///
    /// - Parameters:
    ///   - uid: Unique identifier for reference.
    ///   - email: Email address.
    convenience init(uid: String, email: String) {
        self.init(uid: uid, email: email, contacts: [String]())
    }
    
}
