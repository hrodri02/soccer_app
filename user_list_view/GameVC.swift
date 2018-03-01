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
    // MARK: - Data members
    @IBOutlet weak var tableView: UITableView!
    var playersDict = [String:Player]()
    var players = [Player]()
    var player = Player()
    
    static let ref = Database.database().reference()
    
    var startDateOfGame: Date?
    var endDateOfGame: Date?
    
    var game: Game? {
        didSet {
            if game != nil {
                locationLabel.text = game?.address
                durationLabel.text = "Duration: \((game?.durationHours)!) h \((game?.durationMins)!) m"
                startTimeLabel.text = game?.startTime
                
                let gameStartEndDates = getGameStartEndDate(game?.startTime, game?.durationHours, game?.durationMins)
                startDateOfGame = gameStartEndDates.0
                endDateOfGame = gameStartEndDates.1
            }
            else {
                handleBack()
            }
        }
    }
    
    var datesOfGamesUserHasJoined = [String:(Date,Date)]()
    
    // MARK: - UI components
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
        button.setTitle("Join Game", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleJoinGame), for: .touchUpInside)
        return button
    }()
    
    @objc func handleJoinGame()
    {
        if joinGameButton.titleLabel?.text == "Join Game" {
            if !isTimeConflict() {
                addUserToGame()
            }
            else {
                self.createAlert(title: "Error", msg: "There is a time conflict with another game you are apart of!")
            }
        }
        else {
            removeUserFromGame()
        }
    }
    
    // MARK: - Table View Controller functions
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTVCell", for: indexPath) as? FriendsTVCell
        
        let player: Player = players[indexPath.row]
        
        if player.profileImageURLStr != nil {
            cell?.profileImage.loadImageUsingCacheWithURLStr(urlStr: player.profileImageURLStr!)
        }
        else {
            cell?.profileImage.image = UIImage(named: "soccer_player")
        }
        
        cell?.textLabel?.text = player.name
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
        
        getGamesUserIsPartOf()
        observeNewPlayersOfGame()
        observeExistingPlayersOfGame()
        
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
    
    // MARK: - helper functions
    private func gameStarted() -> Bool {
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"             // Your date format
        let gameDate = dateFormatter.date(from: (game?.startTime)!) // according to date format your date string
        
        if gameDate! <= currentDate {
            return true
        }
        
        return false
    }
    
    private func addUserToGame()
    {
        let gamesRef = GameVC.ref.child("games").child((game?.identifier)!)
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        
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
        let player = [currentUID: true]
        gamesRef.child("players").updateChildValues(player) { (err, ref) in
            if err != nil {
                return
            }
            
            // saved game information into firebase db
        }
        
        // update the games the current user is a part of
        let gamesListRef = GameVC.ref.child("users").child(currentUID).child("games")
        let newGame = [(game?.identifier)! : true]
        gamesListRef.updateChildValues(newGame) {(err, ref) in
            if err != nil {
                return
            }
        }
        
        updateGamesPlayedByUser(1)
    }
    
    
    private func removeUserFromGame() {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        guard let gameId = game?.identifier else {return}
        let gamesRef = GameVC.ref.child("games").child(gameId)
        
        // update the list of players participating in the game
        let player = [currentUID: false]
        gamesRef.child("players").updateChildValues(player) { (err, ref) in
            if err != nil {
                return
            }
            // saved game information into firebase db
        }
        
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
        
        // update the games the current user is a part of
        let userRef = GameVC.ref.child("users").child(currentUID)
        let gamesListRef = userRef.child("games")
        let newGame = [(game?.identifier)! : false]
        gamesListRef.updateChildValues(newGame) {(err, ref) in
            if err != nil {
                return
            }
        }
        
        updateGamesPlayedByUser(-1)
    }
    
    private func isTimeConflict() -> Bool {
        for (_,date) in self.datesOfGamesUserHasJoined {
            let startDate = date.0
            let endDate = date.1
            
            if (startDateOfGame! <= startDate) && (startDate < endDateOfGame!) ||
                (startDateOfGame! < endDate) && (endDate <= endDateOfGame!)
            {
                return true
            }
        }
        return false
    }
    
    private func getGameStartEndDate(_ startTime: String?, _ durHours: Int?, _ durMins: Int?) -> (Date, Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
        let startDate = dateFormatter.date(from: (startTime)!) // according to date format your date string
        
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate!)
        
        // add the duration to the start time
        components.hour = (components.hour)! + (durHours)!
        components.minute = (components.minute)! + (durMins)!
        let endDate = gregorian.date(from: components)!
        return (startDate!,endDate)
    }
    
    private func createAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func updateGamesPlayedByUser(_ changeByOne: Int) {
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        let userRef = Database.database().reference().child("users").child(currentUID)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:AnyObject] {
                var gamesPlayed: Int = 0
                if let gamesPlayedByUser = userDict["gamesPlayed"] as? Int {
                    gamesPlayed = gamesPlayedByUser
                }
                
                gamesPlayed += changeByOne
                
                let values = ["gamesPlayed":gamesPlayed]
                userRef.updateChildValues(values) { (err, _) in
                    if err != nil {
                        print(err!)
                    }
                }
            }
        }, withCancel: nil)
    }
    
    // MARK: - Database observing functions
    func getGamesUserIsPartOf()
    {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let gamesListRef = GameVC.ref.child("users").child(uid).child("games")
        gamesListRef.observe(.childChanged, with: { (snapshot) in
            
            let currentGameId = snapshot.key
            guard let isPartOfGame = snapshot.value as? Bool else {return}
            
            // don't want to check a time conflict for games the user isn't a part of
            if !isPartOfGame {
                self.datesOfGamesUserHasJoined.removeValue(forKey: currentGameId)
                return
            }
            
            // check if there is a time conflict with current game
            let gameRef = GamesVC.ref.child("games").child(currentGameId)
            gameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:AnyObject] {
                    
                    let durationHours = dict["durationHours"] as? String
                    let durHours = Int(durationHours!)
                    let durationMins = dict["durationMins"] as? String
                    let durMins = Int(durationMins!)
                    let startTime = dict["startTime"] as? String
                    
                    self.datesOfGamesUserHasJoined[currentGameId] = self.getGameStartEndDate(startTime, durHours, durMins)
                }
            }, withCancel: nil)
        }, withCancel: nil)
        
        
        gamesListRef.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            
            let currentGameId = snapshot.key
            guard let isPartOfGame = snapshot.value as? Bool else {return}
            
            // don't want to check a time conflict for games the user isn't a part of
            if !isPartOfGame {
                return
            }
            
            // check if there is a time conflict with current game
            let gameRef = GamesVC.ref.child("games").child(currentGameId)
            gameRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dict = snapshot.value as? [String:AnyObject] {
                    
                    let durationHours = dict["durationHours"] as? String
                    let durHours = Int(durationHours!)
                    let durationMins = dict["durationMins"] as? String
                    let durMins = Int(durationMins!)
                    let startTime = dict["startTime"] as? String
                    
                    self.datesOfGamesUserHasJoined[currentGameId] = self.getGameStartEndDate(startTime, durHours, durMins)
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func observeNewPlayersOfGame() {
        guard let gameId = game?.identifier else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let playersRef = Database.database().reference().child("games").child(gameId).child("players")
        playersRef.observe(.childAdded, with: { (snapshot) in
            let playerId = snapshot.key
            let isPartOfGame = snapshot.value as? Bool
            
            let playerRef = Database.database().reference().child("users").child(playerId)
            playerRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let player = Player()
                if let playerDict = snapshot.value as? [String:Any] {
                    player.name = playerDict["name"] as? String
                    player.profileImageURLStr = playerDict["profileImageURL"] as? String
                    
                    if isPartOfGame! {
                        self.playersDict[playerId] = player
                        self.players = Array(self.playersDict.values)
                    }
                        
                    if playerId == uid {
                        if isPartOfGame! {
                            self.joinGameButton.setTitle("Leave Game", for: .normal)
                        }
                        else {
                            self.joinGameButton.setTitle("Join Game", for: .normal)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func observeExistingPlayersOfGame() {
        guard let gameId = game?.identifier else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let playersRef = Database.database().reference().child("games").child(gameId).child("players")
        playersRef.observe(.childChanged, with: { (snapshot) in
            let playerId = snapshot.key
            let isPartOfGame = snapshot.value as? Bool
            
            let playerRef = Database.database().reference().child("users").child(playerId)
            
            
            playerRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let player = Player()
                if let playerDict = snapshot.value as? [String:Any] {
                    player.name = playerDict["name"] as? String
                    player.profileImageURLStr = playerDict["profileImageURL"] as? String
                    
                    if isPartOfGame! {
                        self.playersDict[playerId] = player
                        self.players = Array(self.playersDict.values)
                    }
                    else {
                        self.playersDict.removeValue(forKey: playerId)
                        self.players = Array(self.playersDict.values)
                    }
                    
                    if playerId == uid {
                        if isPartOfGame! {
                                self.joinGameButton.setTitle("Leave Game", for: .normal)
                        }
                        else {
                            self.joinGameButton.setTitle("Join Game", for: .normal)
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    // MARK: - setting constraints on UI elements
    func setupTopLabel()
    {
        topLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
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
    @objc func handleBack()
    {
        performSegue(withIdentifier: "goToGamesVC", sender: nil)
    }
    
    @objc func handleEdit()
    {
        let editGameVC = EditGameVC()
        let navController = UINavigationController(rootViewController: editGameVC)
        editGameVC.game = game
        present(navController, animated: true, completion: nil)
    }
}

