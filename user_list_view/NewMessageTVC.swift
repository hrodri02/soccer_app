//
//  NewMessageTVC.swift
//  user_list_view
//
//  Created by Eri on 1/22/18.
//  Copyright © 2018 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTVC: UITableViewController {
    
    var players = [Player]()
    
    // MARK: - viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .darkColor
        
        navigationItem.title = "Contacts"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(handleBack))
        
        // register custom cell
        self.tableView.register(FriendsTVCell.self, forCellReuseIdentifier: "FriendsTVCell")
        
        getFriendsList()
    }
    
    // MARK: - Table view functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTVCell", for: indexPath) as? FriendsTVCell
        
        let player: Player = players[indexPath.row]
        
        if player.profileImageURLStr != nil
        {
            cell?.profileImage.loadImageUsingCacheWithURLStr(urlStr: player.profileImageURLStr!)
        }
        else
        {
            cell?.profileImage.image = UIImage(named: "soccer_player")
        }
        
        // Configure the cell...
        cell?.detailTextLabel?.text = player.email
        cell?.textLabel?.text = player.name
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = players[indexPath.row]
        let chatLogCVC = ChatLogCVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogCVC.user = player
        let navController = UINavigationController(rootViewController: chatLogCVC)
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Database functions
    func getFriendsList() {
        let friendshipsRef = Database.database().reference().child("friendships")
        let currentUID = Auth.auth().currentUser?.uid
        let myFriendsRef = friendshipsRef.child(currentUID!)
        
        myFriendsRef.observe(.childAdded, with: { (snapshot) in
            
            if let isMyFriend = snapshot.value as? Bool {
                if isMyFriend {
                    self.getFriendsInfo(snapshot.key)
                }
            }
        }, withCancel: nil)
    }
    
    func getFriendsInfo(_ uid: String) {
        let userRef = Database.database().reference().child("users").child(uid)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userDict = snapshot.value as? [String:AnyObject] {
                let player = Player()
                player.name = userDict["name"] as? String
                player.email = userDict["email"] as? String
                player.profileImageURLStr = userDict["profileImageURL"] as? String
                player.uid = uid
                self.players.append(player)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
    }
    
    // MARK: - Navigation
    @objc func handleBack() {
        dismiss(animated: true, completion: nil)
    }
}
