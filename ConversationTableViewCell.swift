//
//  ConversationTableViewCell.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/19/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ConversationTableViewCell: UITableViewCell {
    
    let firebaseDatabaseURL = "https://messanger-36137.firebaseio.com/"
    let conversationsReferencePath = "conversations"
    let messagesReferencePath = "messages"
    let defaultErrorMessage = "Default error message."
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var ref: FIRDatabaseReference!
    var conversation: Conversation?
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        firebase()
        configureViews()
    }
    
    func firebase() {
        ref = FIRDatabase.database().reference(fromURL: firebaseDatabaseURL)
    }
    
    func configureViews() {
        var date = 0.0
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        var letters = [Character]()
        for letter in (nameLabel.text?.characters)! {
            letters.append(letter)
        }
        iconLabel.text = letters.first?.description
        iconLabel.textColor = UIColor.white
        iconLabel.backgroundColor = tintColor
        iconLabel.layer.cornerRadius = iconLabel.frame.width / 2
        let messagesRef = ref.child(conversationsReferencePath).child((conversation?.uid)!).child(messagesReferencePath)
        let messageQuery = messagesRef.queryLimited(toLast: 1)
        messageQuery.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if let list = snapshot.value as? [String : Any] {
                self.messageLabel.text = list["body"] as? String
                date = (list["timestamp"] as? Double)!
                let time = Date(timeIntervalSince1970: date)
                self.timestampLabel.text = dateFormatter.string(from: time)
            }
        })
    }
}
