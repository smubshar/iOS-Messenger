//
//  ConversationsViewController.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/5/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//
import Foundation
import UIKit
import Firebase

protocol UpdateConversationList {
    func update()
}

class ConversationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UpdateConversationList {
    
    let firebaseDatabaseURL = "https://messanger-36137.firebaseio.com/"
    let conversationReferencePath = "conversations"
    let senderKey = "sender"
    let recipientKey = "recipient"
    let numberOfRowsInSection = 1
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var composeBarButtonItem: UIBarButtonItem!
    
    var user: User!
    var ref: FIRDatabaseReference!
    var conversations = [Conversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebase()
        getConversations()
        configureNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func update() {
        self.tableView.reloadData()
    }
    
    func firebase() {
        self.ref = FIRDatabase.database().reference(fromURL: self.firebaseDatabaseURL)
    }
    
    func getConversations() {
        ref.child(conversationReferencePath).observe(.childAdded, with: { (snapshot) in
            if let list = snapshot.value as? [String : Any] {
                let senderUID = list[self.senderKey] as? String
                let recipientUID = list[self.recipientKey] as? String
                
                if list[self.senderKey] as? String == self.user.uid ||
                    list[self.recipientKey] as? String == self.user.uid {
                    let conversationUID = snapshot.key
                    self.getContact(conversationUID: conversationUID, senderUID: senderUID!, recipientUID: recipientUID!)
                }
            }
        }, withCancel: nil)
        self.tableView.reloadData()
    }
    
    func getContact(conversationUID: String, senderUID: String, recipientUID: String) {
        var sender = User(uid: "", email: "")
        var recipient = User(uid: "", email: "")
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            if let list = snapshot.value as? [String : Any] {
                if senderUID == snapshot.key {
                    sender.setValuesForKeys(list)
                    sender.uid = snapshot.key
                } else if recipientUID == snapshot.key {
                    recipient.setValuesForKeys(list)
                    recipient.uid = snapshot.key
                }
            }
            
            if sender.uid != nil && recipient.uid != nil {
                let conversation = Conversation.init(uid: conversationUID, sender: sender, recipient: recipient)
                self.conversations.append(conversation)
                self.tableView.reloadData()
            }
        }, withCancel: nil)
    }
    
    func configureNavigationBar() {
        navigationBar.title = user.email
    }
    
    // TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
        let conversation = conversations[indexPath.row]
        cell.conversation = conversation
        cell.user = user
        if conversation.sender.uid == user.uid {
            cell.nameLabel.text = conversation.recipient.email
        } else {
            cell.nameLabel.text = conversation.sender.email
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            conversations.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let conversationViewController = segue.destination as! ConversationViewController
                let conversation = conversations[indexPath.row]
                conversationViewController.conversation = conversation
                conversationViewController.user = self.user
                conversationViewController.delegate = self
            }
        } else {
            let usersListViewController = segue.destination as! UsersListViewController
            usersListViewController.user = self.user
        }
    }
    
}
