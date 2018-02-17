//
//  FriendsTVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 8/18/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class FriendsTVC: UITableViewController
{
    var players = [Player]()
    var filteredPlayers = [Player]()
    var searchFooter = SearchFooter(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
    
    // nil is to tell search controller to use the same view we are searching to display results
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .darkColor
        
        let friend_requests_image  = UIImage(named: "friend_requests")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: friend_requests_image, style: .plain, target: self, action: #selector(handleFriendRequests))
        
        // for the search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search your friend list"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = searchFooter
        
        searchController.searchBar.barTintColor = .lightColor
        searchController.searchBar.tintColor = .superLightColor
        
        // register custom cell
        self.tableView.register(FriendsTVCell.self, forCellReuseIdentifier: "FriendsTVCell")
        
        observeUserFriends()
    }
    


    @objc func handleFriendRequests()
    {
        let friendRequestTVC = FriendRequestsTVC()
        let navController = UINavigationController(rootViewController: friendRequestTVC)
        present(navController, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTVCell", for: indexPath) as? FriendsTVCell
        
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
        cell?.detailTextLabel?.text = player.email
        cell?.textLabel?.text = player.name
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = players[indexPath.row]
        
        let profileVC = MyFriendVC()
        profileVC.player = player
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func observeUserFriends() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let friendsOfUserRef = Database.database().reference().child("friendships").child(currentUID)
        
        friendsOfUserRef.observe(.childAdded, with: { (snapshot) in
            let friendId = snapshot.key
            let isFriend = snapshot.value as! Bool
            let friendRef = Database.database().reference().child("users").child(friendId)
            
            if isFriend {
                self.getFriendInfo(friendRef)
            }
        }, withCancel: nil)
    }
    
    private func getFriendInfo(_ ref: DatabaseReference) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = snapshot.value as? [String:AnyObject] {
                let player = Player()
                player.name = user["name"] as? String
                player.email = user["email"] as? String
                player.profileImageURLStr = user["profileImageURL"] as? String
                player.profileImageWidth = user["profileImageWidth"] as? NSNumber
                player.profileImageHeight = user["profileImageHeight"] as? NSNumber
                player.backgroundImageURLStr = user["backgroundImageURL"] as? String
                player.videoURLStr = user["videoURLstr"] as? String
                player.experience = user["experience"] as? String
                player.favClubTeam = user["favClubTeam"] as? String
                player.position = user["position"] as? String
                
                
                self.players.append(player)
                self.players.sort(by: { (player1, player2) -> Bool in
                    return player1.name! < player2.name!
                })
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
            }
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
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
    
    @IBAction func unwindFromFriendRequestsTVC(segue:UIStoryboardSegue)
    {
        
    }
}

extension FriendsTVC: UISearchResultsUpdating
{
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
