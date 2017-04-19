//
//  ViewController.swift
//  Messanger
//
//  Created by Shahrukh Mubshar on 12/4/16.
//  Copyright © 2016 Shahrukh Mubshar. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    let unimplemented = "Not implemented"
    let emptyText = ""
    let authenticationAccountAlertControllerTitle = "Oops!"
    let createAccountAlertControllerMessage = "Please enter an email and password."
    let loginAccountAlertControllerMessage = "The username or password is incorrect."
    let authenticationAccountAlertControllerDefaultActionTitle = "OK"
    let loginSegueIdentifier = "loginSegue"
    let firebaseDatabaseURL = "https://messanger-36137.firebaseio.com/"
    let emailKey = "email"
    let contactsKey = "contacts"
    let userReferencePath = "users"
    let defaultErrorMessage = "Default error message."
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Initial setup of view controller.
    func setup() {
        setupRecognizers()
        setupFirebase()
        setupAuthentication()
    }
    
    
    /// Configure and add gesture recognizers.
    func setupRecognizers() {
        let tapViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewOnTap))
        let createAccountTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.createAccountButtonOnTap))
        let loginButtonTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.loginButtonOnTap))
        
        view.addGestureRecognizer(tapViewGestureRecognizer)
        createAccountButton.addGestureRecognizer(createAccountTapGestureRecognizer)
        loginButton.addGestureRecognizer(loginButtonTapGestureRecognizer)
    }

    
    /// Setup firebase.
    func setupFirebase() {
        self.ref = FIRDatabase.database().reference(fromURL: self.firebaseDatabaseURL)
    }
    
    
    /// Setup textfield values.
    func setupAuthentication() {
        if let user = FIRAuth.auth()?.currentUser {
            self.emailTextField.text = user.email
        } else {
            self.emailTextField.text = emptyText
        }
    }
    
    
    func viewOnTap() {
        if emailTextField.isEditing {
            print("Email")
            emailTextField.resignFirstResponder()
        } else if passwordTextField.isEditing {
            print("Password")
            passwordTextField.resignFirstResponder()
        } else {
            // ERROR
        }
    }
    
    func loginButtonOnTap(_ sender: Any?) {
        if emailTextField.text == emptyText || passwordTextField.text == emptyText {
            
            let createAccountAlertController = UIAlertController(title: authenticationAccountAlertControllerTitle, message: createAccountAlertControllerMessage, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: authenticationAccountAlertControllerDefaultActionTitle, style: .cancel, handler: nil)
            
            createAccountAlertController.addAction(defaultAction)
            self.present(createAccountAlertController, animated: true, completion: nil)
            
        } else {
            
            let email = emailTextField.text!
            let password = passwordTextField.text!
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if error == nil {
                    let userID = FIRAuth.auth()?.currentUser?.uid
                    self.ref.child(self.userReferencePath)
                    self.ref.child(self.userReferencePath).child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as! NSDictionary
                        let email = value[self.emailKey] as! String
                        let contacts = value[self.contactsKey] as? [String]
                        self.user = User(uid: userID!, email: email, contacts: contacts!)
                        self.performSegue(withIdentifier: self.loginSegueIdentifier, sender: sender)
                    }) { (error) in
                        print(error)
                    }
                } else {
                    let createAccountAlertController = UIAlertController(title: self.authenticationAccountAlertControllerTitle, message: self.loginAccountAlertControllerMessage, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: self.authenticationAccountAlertControllerDefaultActionTitle, style: .cancel, handler: nil)
                    
                    createAccountAlertController.addAction(defaultAction)
                    self.present(createAccountAlertController, animated: true, completion: nil)
                }
                
            })
        }
    }
    
    func createAccountButtonOnTap() {
        if emailTextField.text == emptyText || passwordTextField.text == emptyText {
            
            let createAccountAlertController = UIAlertController(title: authenticationAccountAlertControllerTitle, message: createAccountAlertControllerMessage, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: authenticationAccountAlertControllerDefaultActionTitle, style: .cancel, handler: nil)
            
            createAccountAlertController.addAction(defaultAction)
            self.present(createAccountAlertController, animated: true, completion: nil)
            
        } else {
            
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    self.emailTextField.text = self.emptyText
                    self.passwordTextField.text = self.emptyText
                    let usersReference = self.ref.child(self.userReferencePath).child((user?.uid)!)
                    var contacts = [String]()
                    // TODO
                    contacts.append("J089geq67HTZUoxYv6oZQun4MO23")
                    let values = [self.emailKey : email, self.contactsKey : contacts] as [String : Any]
                    usersReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                        if error == nil {
                            return
                        }
                        print(error ?? self.defaultErrorMessage)
                    })
                } else {
                    let createAccountAlertController = UIAlertController(title: self.authenticationAccountAlertControllerTitle, message: self.createAccountAlertControllerMessage, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: self.authenticationAccountAlertControllerDefaultActionTitle, style: .cancel, handler: nil)
                    
                    createAccountAlertController.addAction(defaultAction)
                    self.present(createAccountAlertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! ConversationListViewController
        destinationViewController.user = self.user
    }

}

