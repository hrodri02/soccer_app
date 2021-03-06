//
//  FriendsTVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/28/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SuggestedFriendsTVC: UITableViewController
{
    var searchFooter = SearchFooter(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
    
    let searchController = UISearchController(searchResultsController: nil)
    let FIFTY_MILES_IN_METERS = 80450.0
    var players = [Player]()
    var friendRequestsDict = [String:Bool]()
    var friends = [Player]()
    var filteredPlayers = [Player]()
    
    var userLat: Double?
    var userLon: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for the search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Find friends"

        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = searchFooter
        
        self.tableView.backgroundColor = .darkColor
        
        // register a custom table view cell
        self.tableView.register(SuggestedFriendsTVCell.self, forCellReuseIdentifier: "SuggestedFriendsTVCell")
        
        observeUserCoordinate()
        observeSuggestedFriends()
    }
    
    func observeUserCoordinate() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userRef = Database.database().reference().child("users").child(uid)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userDict = snapshot.value as? [String:Any] else {return}
            guard let coor = userDict["coordinate"] as? [String:Double] else {return}
            self.userLat = coor["lat"]
            self.userLon = coor["lon"]
        }, withCancel: nil)
    }

    func observeSuggestedFriends() {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        
        let friendsOfUserRef = Database.database().reference().child("friendships").child(currentUID)
        friendsOfUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let friendsDict = snapshot.value as? [String:Bool] {
                self.friendRequestsDict = friendsDict
            }
        
        }, withCancel: nil)
        
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.childAdded, with: { (snapshot) in
            let uid = snapshot.key
            
            if uid == currentUID {
                return
            }
            
            let ref = Database.database().reference().child("users").child(uid)
            if (self.friendRequestsDict[uid] == nil ||
                self.friendRequestsDict[uid] == false) {
                self.getUserInfo(ref)
            }
        }, withCancel: nil)
    }
    
    private func getUserInfo(_ ref: DatabaseReference) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = snapshot.value as? [String:AnyObject] {
                let player = Player()
                player.uid = snapshot.key
                player.name = user["name"] as? String
                player.email = user["email"] as? String
                player.profileImageURLStr = user["profileImageURL"] as? String
                player.backgroundImageURLStr = user["backgroundImageURL"] as? String
                player.experience = user["experience"] as? String
                player.favClubTeam = user["favClubTeam"] as? String
                player.position = user["position"] as? String
                
                var distanceInMeters: Double? = nil
                if let userLat = self.userLat, let userLon = self.userLon {
                    if let coordinate = user["coordinate"] as? [String:Double] {
                        guard let lat = coordinate["lat"] else {return}
                        guard let lon = coordinate["lon"] else {return}
                        let coor1 = CLLocation(latitude: lat,longitude: lon)
                        let coor2 = CLLocation(latitude: userLat, longitude: userLon)
                        distanceInMeters = coor1.distance(from: coor2)
                    }
                }
                
                if let dstInMeters = distanceInMeters {
                    if dstInMeters <= self.FIFTY_MILES_IN_METERS {
                        self.players.append(player)
                        self.players.sort(by: { (player1, player2) -> Bool in
                            return player1.name! < player2.name!
                        })
                    }
                }
                else {
                    self.players.append(player)
                    self.players.sort(by: { (player1, player2) -> Bool in
                        return player1.name! < player2.name!
                    })
                }
                
                
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredPlayers.count, of: players.count)
            return filteredPlayers.count
        }
        
        searchFooter.setNotFiltering()
        return players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedFriendsTVCell", for: indexPath) as? SuggestedFriendsTVCell
        cell?.contentView.backgroundColor = .darkColor
        cell?.addButton.tag = indexPath.row
        
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
        cell?.textLabel?.text = player.name
        cell?.uid = player.uid
        cell?.textLabel?.backgroundColor = .darkColor
        cell?.textLabel?.textColor = .superLightColor

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPlayers = players.filter({( player : Player) -> Bool in
            return (player.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    // determines if we are currently filtering results
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension SuggestedFriendsTVC: UISearchResultsUpdating
{
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
