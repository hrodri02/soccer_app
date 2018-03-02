//
//  FriendsTVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 8/18/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class FriendRequestsTVC: UITableViewController
{
    
    var friendRequestsDict = [String:Player]()
    var players = [Player]()
    var filteredPlayers = [Player]()
    var searchFooter = SearchFooter(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
    var timer: Timer?
    
    // nil is to tell search controller to use the same view we are searching to display results
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .darkColor
        navigationItem.title = "Friend Requests"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(handleBack))
        
        // for the search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search your friend request list"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = searchFooter
        
        // register custom cell
        self.tableView.register(FriendRequestsTVCell.self, forCellReuseIdentifier: "FriendRequestsTVCell")
        observeFriendRequests()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering()
        {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredPlayers.count, of: players.count)
            return filteredPlayers.count
        }
        
        searchFooter.setNotFiltering()
        return players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestsTVCell", for: indexPath) as? FriendRequestsTVCell
        
        let player: Player
        
        if isFiltering()
        {
            player = filteredPlayers[indexPath.row]
        }
        else
        {
            player = players[indexPath.row]
        }
        
        if player.profileImageURLStr != nil
        {
            cell?.profileImage.loadImageUsingCacheWithURLStr(urlStr: player.profileImageURLStr!)
        }
        else
        {
            cell?.profileImage.image = UIImage(named: "soccer_player")
        }
        
        // Configure the cell...
        cell?.acceptButton.tag = indexPath.row
        cell?.declineButton.tag = indexPath.row
        cell?.acceptButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        cell?.declineButton.addTarget(self, action: #selector(handleDecline), for: .touchUpInside)
        cell?.textLabel?.text = player.name
        
        return cell!
    }
    
    @objc func handleAccept(_ sender: UIButton) {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        guard let otherUID = players[sender.tag].uid else {return}
        let usersRef = Database.database().reference().child("users")
        let friendRequestsRef = usersRef.child(currentUID).child("newFriendRequests").child(otherUID)
        
        players.remove(at: sender.tag)
        tableView.reloadData()
        
        friendRequestsRef.removeValue { (error, _) in
            
            if error != nil {
                print(error!)
                return
            }
            
            // removed friend request from database
        }
        
        let pendingFriendRequestsRef = usersRef.child(otherUID).child("pendingFriendRequests").child(currentUID)
        pendingFriendRequestsRef.removeValue { (err, _) in
            
            if err != nil {
                print(err!)
                return
            }
            
            // updated pending friend requests
        }
        
        // update the friends list of the current user
        let friendshipsRef = Database.database().reference().child("friendships")
        let friendshipsOfCurrentUsrRef = friendshipsRef.child(currentUID)
        let values = [otherUID:true]
        friendshipsOfCurrentUsrRef.updateChildValues(values) { (err, _) in
            if err != nil {
                print(err!)
                return
            }
        }
        
        // update the friends list of the user that sent request
        let senderFriendshipsRef = friendshipsRef.child(otherUID)
        let newFriend = [currentUID:true]
        senderFriendshipsRef.updateChildValues(newFriend) { (err, _) in
            if err != nil {
                print(err!)
                return
            }
        }
        
    }
    
    @objc func handleDecline(_ sender: UIButton) {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        guard let uidToRemove = players[sender.tag].uid else {return}
        let userRef = Database.database().reference().child("users").child(currentUID)
        let friendRequestsRef = userRef.child("newFriendRequests").child(uidToRemove)
        
        players.remove(at: sender.tag)
        tableView.reloadData()
        
        friendRequestsRef.removeValue { (error, _) in
            
            if error != nil {
                print(error!)
            }
            
            // removed friend request from database
        }
        
        let pendingFriendRequestsRef = Database.database().reference().child("users").child(uidToRemove).child("pendingFriendRequests")
        let values = [currentUID: false]
        pendingFriendRequestsRef.updateChildValues(values) { (err, ref) in
            
            if err != nil {
                print(err!)
            }
            
            // updated pending friend requests
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let player = players[indexPath.row]
        
        let profileVC = MyFriendVC()
        
        profileVC.player = player
        profileVC.nameLabel.text = player.name
        profileVC.gamesPlayed.text = ""
        profileVC.gamesCreated.text = ""
        profileVC.experience.text = player.experience
        profileVC.favoriteClubTeam.text = player.favClubTeam
        profileVC.position.text = player.position
        
        /* Note: it might be better to save the profile image downloaded in the cellForRowAt func */
        if player.profileImageURLStr != nil
        {
            profileVC.profileImage.loadImageUsingCacheWithURLStr(urlStr: player.profileImageURLStr!)
        }
        
        if player.backgroundImageURLStr != nil
        {
            profileVC.backgroundImageView.loadImageUsingCacheWithURLStr(urlStr: player.backgroundImageURLStr!)
        }
        
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    func observeFriendRequests()
    {
        let usersRef = Database.database().reference().child("users")
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        let newFriendRequestRef = usersRef.child(currentUID).child("newFriendRequests")
        
        newFriendRequestRef.observe(.childAdded, with: { (snapshot) in
            let uid = snapshot.key
            self.downloadPlayerInfo(uid)
        }, withCancel: nil)
    }
    
    func downloadPlayerInfo(_ uid: String)
    {
        let usersRef = Database.database().reference().child("users").child(uid)
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let playerDict = snapshot.value as? [String:AnyObject] {
                let player = Player()
                player.name = playerDict["name"] as? String
                player.profileImageURLStr = playerDict["profileImageURL"] as? String
                player.uid = uid
                self.players.append(player)
                self.attemptToReloadTable()
            }
        }, withCancel: nil)
    }
    
    func attemptToReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.players.sort(by: { (player1, player2) -> Bool in
            return player1.name! < player2.name!
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    // MARK - Private instance methods
    
    func searchBarIsEmtpy() -> Bool
    {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")
    {
        filteredPlayers = players.filter({ (player: Player) -> Bool in
            return (player.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    // determine if we are currently filtering results
    func isFiltering() -> Bool
    {
        return searchController.isActive && !searchBarIsEmtpy()
    }
    
    // MARK: - Navigation
    @objc func handleBack()
    {
        dismiss(animated: true, completion: nil)
    }
}

extension FriendRequestsTVC: UISearchResultsUpdating
{
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
