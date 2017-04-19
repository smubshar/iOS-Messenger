//
//  DAO.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/20/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation
import Firebase

/// A class for interacting with database
class DAO {
    
    var ref: FIRDatabaseReference!
    let firebaseDatabaseURL = "https://messanger-36137.firebaseio.com/"
    let conversationReferencePath = "conversations"
    let senderKey = "sender"
    let recipientKey = "recipient"
    let defaultErrorMessage = "Default error message."
    
    
    /// Constructor for DAO.
    public init() {
        ref = FIRDatabase.database().reference(fromURL: firebaseDatabaseURL)
    }
    
    /// Add object to database
    ///
    /// - Parameters:
    ///   - values: Dictionary of entries values.
    ///   - referencePath: Reference path in database to insert entry.
    /// - Returns: Unique identifier for reference.
    func add(these values: [String : Any], to referencePath: String) -> String? {
        var uid: String? = nil
        ref.child(referencePath).updateChildValues(values, withCompletionBlock: { (error, reference) in
            if error == nil {
                uid = reference.key
            } else {
                print(self.defaultErrorMessage)
            }
        })
        
        return uid
    }
    
    /// Retrieval of object from database.
    ///
    /// - Parameter referencePath: Reference path in databse to retrieve entry.
    /// - Returns: List of dictionaries representing the entries at the reference path.
    func get(from referencePath: String) -> [ [String : Any]? ] {
        var list = [ [String : Any] ]()
        
        ref.child(referencePath).observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            if let value = snapshot.value as? [String : Any] {
                list.append(value)
            }
        })
        
        return list
    }
}
