//
//  ConversationViewController.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/17/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let numberOfSection = 1
    let emptyText = ""
    let firebaseDatabaseURL = "https://messanger-36137.firebaseio.com/"
    let conversationsReferencePath = "conversations"
    let messagesReferencePath = "messages"
    let defaultErrorMessage = "Default error message."
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleNav: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var interactionView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var interactionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    var user: User!
    var recipient: User!
    var conversation: Conversation!
    var ref: FIRDatabaseReference!
    var delegate: UpdateConversationList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebase()
        configureData()
        configureViews()
        recognizers()
        loadMessage()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationNotification(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureData() {
        if user.uid == conversation.sender.uid {
            recipient = conversation.recipient
        } else {
            recipient = conversation.sender
        }
    }
    
    func configureViews() {
        if user.uid == conversation.sender.uid {
            titleNav.title = conversation.recipient.email
        } else {
            titleNav.title = conversation.sender.email
        }
        
        bodyTextView.layer.cornerRadius = 14
        bodyTextView.isScrollEnabled = false
        
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.backItemOnTap))
        let backButton = UIButton(type: .system)
        backButton.addGestureRecognizer(recognizer)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.setTitle(" Messages", for: .normal)
        backButton.sizeToFit()
        let backItem = UIBarButtonItem(customView: backButton)
        titleNav.leftBarButtonItem = backItem
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func orientationNotification(notification: NSNotification) {
        self.tableView.reloadData()
        tableViewScrollToBottom(animated: true)
    }
    
    func backItemOnTap() {
        resignFirstResponder()
        delegate?.update()
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func recognizers() {
        let sendButtonTapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(self.sendButtonOnTap))
        let tableViewTapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(self.tableViewOnTap))
        tableView.addGestureRecognizer(tableViewTapGestureRecognizer)
        sendButton.addGestureRecognizer(sendButtonTapGestureRecognizer)
    }
    
    func firebase() {
        ref = FIRDatabase.database().reference(fromURL: firebaseDatabaseURL)
    }
    
    func tableViewOnTap() {
        bodyTextView.resignFirstResponder()
        keyboardHeightLayoutConstraint.constant = 0
        interactionView.layoutIfNeeded()
    }
    
    func sendButtonOnTap() {
        let date: Double = NSDate().timeIntervalSince1970
        let text = bodyTextView.text
        if text == emptyText {
            return
        }
        bodyTextView.text = emptyText
        
        let values = ["senderID" : self.user.uid, "recipientID" : self.recipient.uid, "timestamp" : date,
                      "body" : text] as [String : Any]
        ref.child(conversationsReferencePath).child((conversation.uid)).child(messagesReferencePath).childByAutoId().updateChildValues(values, withCompletionBlock: { (error, reference) in
            if error == nil {
                return
            }
            print(error ?? self.defaultErrorMessage)
        })
    }
    
    func loadMessage() {
        let messagesRef = ref.child(conversationsReferencePath).child(conversation.uid).child(messagesReferencePath)
        
        let messagesQuery = messagesRef.queryLimited(toLast: 25)
        messagesQuery.observe(.childAdded, with: { (snapshot) in
            let uid = snapshot.key
            let list = snapshot.value as? [String : Any]
            let senderID = list?["senderID"] as? String
            let recipientID = list?["recipientID"] as? String
            let timestamp = list?["timestamp"] as? Double
            let body = list?["body"] as? String
            let message = Message(uid: uid, senderUID: senderID!, recipientUID: recipientID!, timeStamp: timestamp!, body: body!)
            
            if !(self.conversation.messages.contains(message)) {
                self.conversation.messages.append(message)
            }
            self.tableView.reloadData()
            self.tableViewScrollToBottom(animated: true)
        })
    }
    
    // TableView stuff
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        let message = conversation.messages[indexPath.row]
        cell.bodyTextLabel.text = message.body
        let originalString: String = (message.body)
        let myString: NSString = originalString as NSString
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 14.0)]
        let size = myString.size(attributes: attributes)
        let textWidth = size.width
        if message.senderUID == user.uid {
            cell.style(color: nil, isSender: true, textWidth: textWidth)
        } else {
            cell.style(color: UIColor.lightGray, isSender: false, textWidth: textWidth)
        }
        
        return cell
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
}
