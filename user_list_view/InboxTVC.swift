//
//  InboxTVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/16/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class InboxTVC: UITableViewController {
    // MARK: - data members
    var messages = [Message]()
    var messagesDict = [String : Message]()
    var users = [Player]()
    var timer: Timer?

    // MARK: - viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .darkColor
        navigationItem.title = "Inbox"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        self.tableView.register(InboxTVCell.self, forCellReuseIdentifier: "InboxTVCell")
        tableView.allowsSelectionDuringEditing = true
        
        fetchCurrentUser()
        observeUserMessages()
    }

    // MARK: - Table view controller functions
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        
        let message = messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            let messageRef = Database.database().reference().child("user-messages").child(uid).child(chatPartnerId)
            messageRef.removeValue(completionBlock: { (err, _) in
                
                if (err != nil) {
                    print("Error: could not remove message:", err!)
                }
                
                self.messagesDict.removeValue(forKey: chatPartnerId)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messagesDict.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxTVCell", for: indexPath) as? InboxTVCell
        
        let message = messages[indexPath.row]
        cell?.message = message

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:AnyObject] else {
                return
            }
            
            let player = Player()
            player.name = dict["name"] as? String
            player.email = dict["email"] as? String
            player.uid = chatPartnerId
            player.profileImageURLStr = dict["profileImageURL"] as? String
            
            let chatLogCVC = ChatLogCVC(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogCVC.user = player
            let navController = UINavigationController(rootViewController: chatLogCVC)
            self.present(navController, animated: true, completion: nil)
        }, withCancel: nil)
    }
    
    // MARK: database functions
    func fetchCurrentUser()
    {
        let currentUID = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("users").child(currentUID!)
        userRef.observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = Player()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
    }
    
    func observeUserMessages() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(currentUID)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let uid = snapshot.key
            let msgsWithUIDRef = Database.database().reference().child("user-messages").child(currentUID).child(uid)
            
            msgsWithUIDRef.observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.getMessage(with: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            let chatpartnerId = snapshot.key // this is not the messageId, it is the chat partner ID
            let messDict = snapshot.value as? [String:Int]
            self.messagesDict.removeValue(forKey: chatpartnerId)
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
            
            if let dict = messDict {
             
                for (msgId, _) in dict {
                    
                    let messagesRef = Database.database().reference().child("messages").child(msgId)
                    messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let msgDict = snapshot.value as? [String:AnyObject] {
                            let count = msgDict["counter"] as? NSNumber
                            
                            if count == 2 {
                                // decrement counter
                                let values = ["counter": 1]
                                messagesRef.updateChildValues(values)
                                
                            }
                            else if count == 1 {
                                // remove message from messages node
                                messagesRef.removeValue(completionBlock: { (err, _) in
                                    if err != nil {
                                        print (err!)
                                    }
                                    // removed message successfully
                                })
                            }
                        }
                        
                    }, withCancel: nil)
                    
                }
            }
            
        }, withCancel: nil)
    }
    
    private func getMessage(with messageId: String) {
        let messagesRef = Database.database().reference().child("messages").child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                
                if dictionary["imageURL"] != nil {
                    message.counter = dictionary["counter"] as? NSNumber
                    message.fromId = dictionary["fromId"] as? String
                    message.text = dictionary["text"] as? String
                    message.timestamp = dictionary["timestamp"] as? NSNumber
                    message.toId = dictionary["toId"] as? String
                    message.imageURL = dictionary["imageURL"] as? String
                    message.imageWidth = dictionary["imageWidth"] as? NSNumber
                    message.imageHeight = dictionary["imageHeight"] as? NSNumber
                }
                else {
                    message.counter = dictionary["counter"] as? NSNumber
                    message.fromId = dictionary["fromId"] as? String
                    message.text = dictionary["text"] as? String
                    message.timestamp = dictionary["timestamp"] as? NSNumber
                    message.toId = dictionary["toId"] as? String
                }
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDict[chatPartnerId] = message
                }
                
                self.attemptToReloadTable()
            }
            
        }, withCancel: nil)
    }
    
    func attemptToReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDict.values)
        self.messages.sort(by: { (msg1, msg2) -> Bool in
            return (msg1.timestamp?.intValue)! > (msg2.timestamp?.intValue)!
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Navigation
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        if let presenter = presentingViewController as? LoginVC {
            presenter.emailTextField.text = ""
            presenter.passwordTextField.text = ""
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNewMessage() {
        let newMessageTVC = NewMessageTVC()
        let navController = UINavigationController(rootViewController: newMessageTVC)
        present(navController, animated: true, completion: nil)
    }
}
