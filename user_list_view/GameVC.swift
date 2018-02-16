//
//  GameVC.swift
//  user_list_view
//
//  Created by Eri on 12/4/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class GameVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    // consider using a hash instead of an array for faster lookup
    var players = [Player]()
    var player = Player()
    
    static let ref = Database.database().reference()
    
    var game: Game? {
        didSet {
            if game != nil {
                locationLabel.text = game?.address
                durationLabel.text = "Duration: \((game?.durationHours)!) h \((game?.durationMins)!) m"
                startTimeLabel.text = game?.startTime
            }
            else {
                handleBack()
            }
        }
    }
    
    var canUserJoinGame: Bool? {
        didSet {
            if canUserJoinGame! {
                print("usr is not part of game")
                addUserToGame()
            }
            else {
                print("usr is part of game")
            }
        }
    }
    
    var gamesList: [String]? {
        didSet {
            print("list of games that user is a part of have been downloaded")
            print(gamesList!)
            calcExpirationDates()
        }
    }
    
    var playersDict: [String:Bool]? {
        didSet {
            print("list of players that are part of the game have been downloaded")
            downloadPlayersInfo()
        }
    }
    
    var expirationDates: [(Date,Date)]? {
        didSet {
            print("expirations dates have been calculated")
            print(expirationDates!)
            isUserPartOfGame()
        }
    }
    
    let startTimeLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = ""
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let durationLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "2 hr"
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let topLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "This game will take place at"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var locationLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "Santa Rosa Park"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let centerLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "Players Participating"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var joinGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitleColor(.superLightColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleJoinGame), for: .touchUpInside)
        return button
    }()
    
    func downloadPlayersInfo()
    {
        let currentUID = Auth.auth().currentUser?.uid
        var isCurrentUserPartOfGame = false
        
        for (playerId, isPartOfGame) in playersDict!
        {
            if isPartOfGame {
                
                if playerId == currentUID {
                    isCurrentUserPartOfGame = true
                }
             
                // gets the user information
                let userRef = GameVC.ref.child("users").child(playerId)
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject]
                    {
                        let player =  Player()
                        player.name = dictionary["name"] as? String
                        player.profileImageURLStr = dictionary["profileImageURL"] as? String
                        player.email = dictionary["email"] as? String
                        player.gamesPlayed = dictionary["gamesPlayed"] as? Int
                        player.uid = playerId
                        self.players.append(player)
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                }, withCancel: nil)
                
                
            }
            else {
                isCurrentUserPartOfGame = false
            }
        }
        
        if !isCurrentUserPartOfGame {
            joinGameButton.setTitle("Join Game", for: .normal)
        }
        else {
            joinGameButton.setTitle("Leave Game", for: .normal)
        }
    }
    
    func getPlayersOfGame()
    {
        let playersRef = GameVC.ref.child("games").child((game?.identifier)!).child("players")
        playersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Note: if the game object in the database and in my code had all the same propeties,
            // would copying be easier
            if let dict = snapshot.value as? [String:Bool] {
                self.playersDict = dict
            }
            else {
                self.joinGameButton.setTitle("Join Game", for: .normal)
            }
            
        }, withCancel: nil)
    }
    
    func handleJoinGame()
    {
        // check if the user is already part of the game
        // check the games that the user is a part of
        let currentUID = Auth.auth().currentUser?.uid
        
        if joinGameButton.titleLabel?.text == "Join Game" {
            
            checkGamesThatUserJoined(currentUID)
        }
        else {
            let gamesRef = GameVC.ref.child("games").child((game?.identifier)!)
            
            joinGameButton.setTitle("Join Game", for: .normal)
            
            print(players)
            
            // Find the player that wants to leave the game
            var indexToRemove: Int = 0
            for (i, player) in players.enumerated() {
                print("\(i): " + player.uid!)
                if player.uid! == currentUID {
                    indexToRemove = i
                }
            }
            // remove them from the game
            players.remove(at: indexToRemove)
            tableView.reloadData()
            
            // update the number of players
            game?.numPlayers! -= 1
            
            // update the number of players in database
            let values = ["numPlayers": "\((game?.numPlayers)!)"]
            gamesRef.updateChildValues(values) { (err, ref) in
                if err != nil {
                    return
                }
                // saved game information into firebase db
            }
            
            // update the list of players participating in the game
            let player = [currentUID!: false]
            gamesRef.child("players").updateChildValues(player) { (err, ref) in
                if err != nil {
                    return
                }
                print("added player")
                // saved game information into firebase db
            }
            
            // update the games the current user is a part of
            let userRef = GameVC.ref.child("users").child(currentUID!)
            let gamesListRef = userRef.child("games")
            let newGame = [(game?.identifier)! : false]
            gamesListRef.updateChildValues(newGame) {(err, ref) in
                if err != nil {
                    return
                }
                print("added game to game list of player")
            }
            
            updateGamesPlayedByUser(-1)
        }
    }
    
    func checkGamesThatUserJoined(_ uid: String?)
    {
        let gamesListRef = GameVC.ref.child("users").child(uid!).child("games")
        gamesListRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String:Bool] {
                
                var tempArray: [String] = []
                
                // get the list of games that user is a part of
                for (uid, isPartOfGame) in dict {
                    if isPartOfGame {
                        tempArray.append(uid)
                    }
                }
                
                self.gamesList = tempArray
            }
            else {
                // no players are part of the game
                self.gamesList = []
                print("User is not part of any games")
            }
        }, withCancel: nil)
    }
    
    func calcExpirationDates()
    {
        var tempArray: [(Date, Date)] = []
        
        if gamesList?.count == 0 {
            expirationDates = []
            return
        }
        
        for gameId in gamesList!
        {
            let gameRef = GamesVC.ref.child("games").child(gameId)
            gameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String:AnyObject] {
                    
                    let durationHours = dict["durationHours"] as? String
                    let durHours = Int(durationHours!)
                    let durationMins = dict["durationMins"] as? String
                    let durMins = Int(durationMins!)
                    let startTime = dict["startTime"] as? String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
                    let gameDate = dateFormatter.date(from: (startTime)!) // according to date format your date string
                    
                    let gregorian = Calendar(identifier: .gregorian)
                    var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: gameDate!)
                    
                    // add the duration to the start time
                    components.hour = (components.hour)! + (durHours)!
                    components.minute = (components.minute)! + (durMins)!
                    let expDate = gregorian.date(from: components)!
                    
                    tempArray.append((gameDate!, expDate))
                    if tempArray.count == self.gamesList?.count {
                        self.expirationDates = tempArray
                    }
                }
                else {
                    // no players are part of the game
                    print("No players are part of this game")
                    
                }
            }, withCancel: nil)
        }
    }
    
    func isUserPartOfGame() {
        let currentUID = Auth.auth().currentUser?.uid
        let playersOfGameRef = GameVC.ref.child("games").child((game?.identifier)!).child("players")
        
        playersOfGameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // check that the game the user is trying to join doesn't overlap with another game that they are a part of
            var canJoinGame = true
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
            let startDateOfNewGame = dateFormatter.date(from: (self.game?.startTime)!) // according to date format your date string
            
            let gregorian = Calendar(identifier: .gregorian)
            var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDateOfNewGame!)
            
            // add the duration to the start time
            components.hour = (components.hour)! + (self.game?.durationHours)!
            components.minute = (components.minute)! + (self.game?.durationMins)!
            let expDateOfNewGame = gregorian.date(from: components)!
            
            for dates in self.expirationDates! {
                let startDate = dates.0
                let endDate = dates.1
                
                if (startDateOfNewGame! <= startDate) && (startDate < expDateOfNewGame) ||
                    (startDateOfNewGame! < endDate) && (endDate <= expDateOfNewGame)
                {
                    self.createAlert(title: "Error", msg: "There is a time conflict with another game you are apart of")
                    canJoinGame = false
                    break
                }
            }
            
            if canJoinGame {
                // check if the user is already part of the game
                if let dict = snapshot.value as? [String:Bool] {
                    print(dict)
                    
                    if let isUsrPartOfGame = dict[currentUID!] {
                        // NOTE: don't think this will ever execute but I will leave it for now
                        self.canUserJoinGame = !isUsrPartOfGame
                    }
                    else {
                        self.canUserJoinGame = true
                    }
                    
                }
                else {
                    // no players are part of the game
                    self.canUserJoinGame = true
                }
            }
            else {
                // user can't join game because their is a time conflict with another game
                self.canUserJoinGame = false
            }
            
            
        }, withCancel: nil)
    }
    
    func createAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func addUserToGame()
    {
        let gamesRef = GameVC.ref.child("games").child((game?.identifier)!)
        let currentUID = Auth.auth().currentUser?.uid
        
        // increment the number of players that are part of the game
        game?.numPlayers! += 1
        
        // Change text in button to leave game
        joinGameButton.setTitle("Leave Game", for: .normal)
        
        // update the number of players participating in the game
        let values = ["numPlayers": "\((game?.numPlayers)!)"]
        gamesRef.updateChildValues(values) { (err, ref) in
            if err != nil {
                return
            }
            // saved game information into firebase db
        }
        
        // update the list of players participating in the game
        let player = [currentUID!: true]
        gamesRef.child("players").updateChildValues(player) { (err, ref) in
            if err != nil {
                return
            }
            
            // saved game information into firebase db
        }
        
        // gets the user information
        let userRef = GameVC.ref.child("users").child(currentUID!)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]
            {
                let player =  Player()
                player.name = dictionary["name"] as? String
                player.profileImageURLStr = dictionary["profileImageURL"] as? String
                player.email = dictionary["email"] as? String
                player.uid = currentUID
                self.players.append(player)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }, withCancel: nil)
        
        // update the games the current user is a part of
        let gamesListRef = userRef.child("games")
        let newGame = [(game?.identifier)! : true]
        gamesListRef.updateChildValues(newGame) {(err, ref) in
            if err != nil {
                return
            }
            print("added game to game list of player")
        }
        
        updateGamesPlayedByUser(1)
    }
    
    func downloadPlayerInfo() {
        let currentUID = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("users").child(currentUID!)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:AnyObject] {
                if let gamesPlayedByUser = userDict["gamesPlayed"] as? Int {
                    self.player.gamesPlayed = gamesPlayedByUser
                }
                else {
                    self.player.gamesPlayed = 0
                }
            }
        }, withCancel: nil)
    }
    
    func updateGamesPlayedByUser(_ changeByOne: Int) {
        let currentUID = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("users").child(currentUID!)
        player.gamesPlayed! += changeByOne
        let values = ["gamesPlayed": player.gamesPlayed!]
        userRef.updateChildValues(values) { (err, _) in
            if err != nil {
                print(err!)
            }
        }
        
    }
    
    // MARK: - Table View Controller functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTVCell", for: indexPath) as? FriendsTVCell
        
        let player: Player = players[indexPath.row]
        
        print(players)
        
        print(indexPath.row)
        print(player.uid!)
        
        if player.profileImageURLStr != nil {
            cell?.profileImage.loadImageUsingCacheWithURLStr(urlStr: player.profileImageURLStr!)
        }
        else {
            cell?.profileImage.image = UIImage(named: "soccer_player")
        }
        
        cell?.textLabel?.text = player.name
        cell?.detailTextLabel?.text = player.email
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        tableView.backgroundColor = .darkColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(handleBack))
        
        // only user who created game can edit it
        let currentUID = Auth.auth().currentUser?.uid
        if game?.identifier == currentUID {
            // if the game already began, then you can't edit it
            if !gameStarted() {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdit))
            }
        }
        
        // register custom cell
        self.tableView.register(FriendsTVCell.self, forCellReuseIdentifier: "FriendsTVCell")
        
        getPlayersOfGame()
        downloadPlayerInfo()
        
        view.addSubview(topLabel)
        view.addSubview(durationLabel)
        view.addSubview(locationLabel)
        view.addSubview(startTimeLabel)
        view.addSubview(centerLabel)
        view.addSubview(joinGameButton)
        
        setupTopLabel()
        setupDurationLabel()
        setupLocationLabel()
        setupStartTimeLabel()
        setupJoinGameButton()
        setupCenterLabel()
    }
    
    func gameStarted() -> Bool {
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"             // Your date format
        let gameDate = dateFormatter.date(from: (game?.startTime)!) // according to date format your date string
        
        if gameDate! <= currentDate {
            return true
        }
        
        return false
    }
    
    // MARK: - setting constraints on UI elements
    func setupTopLabel()
    {
        topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 12).isActive = true
        topLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        topLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupLocationLabel()
    {
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 12).isActive = true
        locationLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupDurationLabel()
    {
        durationLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        durationLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12).isActive = true
        durationLabel.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        durationLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    
    func setupStartTimeLabel()
    {
        startTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        startTimeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12).isActive = true
        startTimeLabel.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        startTimeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupCenterLabel()
    {
        centerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -12).isActive = true
        centerLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        centerLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupJoinGameButton()
    {
        joinGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        joinGameButton.topAnchor.constraint(equalTo: startTimeLabel.bottomAnchor, constant: 12).isActive = true
        joinGameButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        joinGameButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    // MARK: - Navigation
    func handleBack()
    {
        performSegue(withIdentifier: "goToGamesVC", sender: nil)
    }
    
    func handleEdit()
    {
        let editGameVC = EditGameVC()
        let navController = UINavigationController(rootViewController: editGameVC)
        editGameVC.game = game
        present(navController, animated: true, completion: nil)
    }
}

