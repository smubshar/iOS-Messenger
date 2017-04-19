//
//  UsersListViewController.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/17/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UsersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let numberOfSection = 1
    let firebaseDatabaseURL = "https://messanger-36137.firebaseio.com/"
    let conversationsReferencePath = "conversations"
    let defaultErrorMessage = "Default error message."
    let dao = DAO.init()
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    var user: User!
    var contactsFriendly = [User]()
    var conversation: Conversation!

    override func viewDidLoad() {
        super.viewDidLoad()
        firebase()
        getContacts()
        recognizers()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func recognizers() {
        cancelBarButton.action = #selector(self.cancelBarButtonOnTap)
    }
    
    func firebase() {
        ref = FIRDatabase.database().reference(fromURL: firebaseDatabaseURL)
    }
    
    func getContacts() {
        if (user?.contacts.count)! <= 0 {
            return
        }
        
        let referencePath = ReferencePath.users
        let list = dao.get(from: referencePath)
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            if let list = snapshot.value as? [String : Any] {
                if (self.user?.contacts.contains(snapshot.key))! {
                    let contact = User(uid: "", email: "")
                    contact.setValuesForKeys(list)
                    contact.uid = snapshot.key
                    self.contactsFriendly.append(contact)
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    func cancelBarButtonOnTap() {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    // TableView stuff
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user != nil {
            return contactsFriendly.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = contactsFriendly[indexPath.row].email
        let cellTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.cellOnTap))
        cell.addGestureRecognizer(cellTapGestureRecognizer)
        return cell
    }
    
    func cellOnTap(_ sender : UITapGestureRecognizer) {
        let point = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let recipient = contactsFriendly[(indexPath?.row)!]
        let values = ["sender" : self.user?.uid, "recipient" : recipient.uid]
        ref.child(conversationsReferencePath).childByAutoId().updateChildValues(values, withCompletionBlock: { (error, reference) in
            
            if error == nil {
                self.conversation = Conversation(uid: reference.key, sender: self.user!, recipient: recipient)
               
                self.performSegue(withIdentifier: "Cell", sender: sender)
            }
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let conversationViewController = segue.destination as! ConversationViewController
        conversationViewController.user = self.user
        conversationViewController.conversation = conversation
    }
}
