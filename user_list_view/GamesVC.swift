//
//  ViewController.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/6/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import UserNotifications

class GamesVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{
    @IBOutlet weak var map: MKMapView!
    
    // used to get the current user's location
    let manager = CLLocationManager()
    
    static let ref = Database.database().reference()
    
    var games: [String:Game] = [:]
    var gameSelected: Game?
    var oldAddress: String?
    var oldCoordinate: CLLocationCoordinate2D?
    
    var newGame: Game? {
        didSet {
            games[(newGame?.identifier)!] = newGame
            annotateLocation(newGame!)
        }
    }
    
    var gamesInDB: [String:AnyObject]? {
        didSet {
            createGamesFromDict(gamesInDB!)
        }
    }
    
    private static var gameId: String?
    
    static var playersOfGame: [String:Bool]? {
        didSet {
            removeGameFromGamesList()
        }
    }
    
    var timer: Timer?
    
    // O(N): have to go through all games in DB to check if they are expired
    func createGamesFromDict(_ dictionary: [String:AnyObject])
    {
        var pin: Game?
        for (uid, soccerGame) in dictionary {
            
            let gameDict = soccerGame as! [String:AnyObject]
            
            pin = Game()
            pin?.identifier = uid
            pin?.address = gameDict["address"] as? String
            
            let durationHours = gameDict["durationHours"] as? String
            pin?.durationHours = Int(durationHours!)
            
            let durationMins = gameDict["durationMins"] as? String
            pin?.durationMins = Int(durationMins!)
            
            let startTime = gameDict["startTime"] as? String
            pin?.startTime = startTime
            
            let numPlayers = gameDict["numPlayers"] as? String
            pin?.numPlayers = Int(numPlayers!)
            
            if gameExpired(pin) {
                GamesVC.gameId = uid
                GamesVC.getPlayersList(uid)
            }
            else {
                games[uid] = pin
            }
            
            print("")
        }
        
        for pin in self.games.values {
            self.annotateLocation(pin)
        }
    }
    
    func gameExpired(_ game: Game?) -> Bool
    {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"             // Your date format
        let gameDate = dateFormatter.date(from: (game?.startTime)!) // according to date format your date string
        
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: gameDate!)
        
        // add the duration to the start time
        components.hour = (components.hour)! + (game?.durationHours)!
        components.minute = (components.minute)! + (game?.durationMins)!
        let expDate = gregorian.date(from: components)!
        
        if expDate >= currentDate {
            return false
        }
        
        return true
    }
    
    static func getPlayersList(_ gameId: String) {
        // get the player list of the game
        let playersRef = ref.child("games").child(gameId).child("players")
        playersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Note: if the game object in the database and in my code had all the same propeties,
            // would copying be easier
            if let dict = snapshot.value as? [String:Bool] {
                GamesVC.playersOfGame = dict
            }
            
            GamesVC.removeGame(gameId)
        }, withCancel: nil)
    }
    
    static func removeGame(_ child: String) {
        let gameRef = self.ref.child("games").child(child)
        
        // remove game from games node
        gameRef.removeValue { error, _ in
            
            if error != nil {
                print(error!)
            }
            
            // successfully removed game
        }
    }
    
    static func removeGameFromGamesList()
    {
        if let players = playersOfGame
        {
            for (player, _) in players {
                let gameRef = ref.child("users").child(player).child("games").child(gameId!)
                
                // remove game from games node
                gameRef.removeValue { error, _ in
                    
                    if error != nil {
                        print(error!)
                    }
                    
                    // successfully removed game
                }
            }
        }
    }
    
    func downloadGames()
    {
        let gamesRef = Database.database().reference().child("games")
        gamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Note: if the game object in the database and in my code had all the same propeties,
            // would copying be easier
            if let dict = snapshot.value as? [String:AnyObject] {
                self.gamesInDB = dict
            }
        }, withCancel: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(handleAddButton))
        
        
        map.delegate = self
        
        // get the current location of a user
        configureLocationManager()
        
        // download active games from firebase
        downloadGames()
        
        observeGames()
        
        // request authorization to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("notification access granted")
            }
            else
            {
                print((error?.localizedDescription)!)
            }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(handleReloadMap), userInfo: nil, repeats: true)
    }
    
    func observeGames()
    {
        let ref = Database.database().reference().child("games")
        
        ref.observe(.childRemoved, with: { (snapshot) in
            let gameId = snapshot.key
            let game = self.games[gameId]
            
            if game?.numPlayers != 0 {
                if let gameDict = snapshot.value as? [String:AnyObject] {
                    let playersDict = gameDict["players"] as? [String:Bool]
                    
                    
                    if let players = playersDict {
                        
                        var i = 0
                        for (player, _) in players {
                            let gameRef = Database.database().reference().child("users").child(player).child("games").child(gameId)
                            
                            // remove game from games node
                            gameRef.removeValue { error, _ in
                                
                                if error != nil {
                                    print(error!)
                                }
                                
                                // successfully removed game
                                i += 1
                                if i == game?.numPlayers {
                                    self.removeAnnotation(game)
                                    self.games[gameId] = nil
                                }
                                
                            }
                        }
                    }
                    
                }
            }
            else {
                print("removing game with no players")
                // removes game from map
                self.removeAnnotation(game)
                self.games[gameId] = nil
            }
         
        }, withCancel: nil)
    }
    
    @objc func handleReloadMap() {
        for (uid, soccerGame) in games {
            if gameExpired(soccerGame) {
                GamesVC.gameId = uid
                
                if soccerGame.numPlayers != 0 {
                    GamesVC.getPlayersList(uid)
                }
                else {
                    // removes game from database
                    GamesVC.removeGame(uid)
                    // removes game from map
                    removeAnnotation(soccerGame)
                    
                    games[uid] = nil
                }
            }
        }
    }
    
    
    @objc func handleLogout()
    {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        performSegue(withIdentifier: "goToLoginVC", sender: nil)
    }
    
    func annotateLocation(_ pin: Game)
    {
        // Every pin needs to have there own geocoder, otherwiae only the first pin will be annotated
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(pin.title!) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            
            if let placemark = placemarks?.first {
                let coordinate = (placemark.location?.coordinate)!
                pin.coordinate = coordinate
                self.map.addAnnotation(pin)
                
            }
        }
    }
    
    func removeAnnotation(_ game: Game?)
    {
        if let annotation = game {
            self.map.removeAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let pin = annotation as? Game
        {
            let annotationView = MKAnnotationView(annotation: pin, reuseIdentifier: pin.identifier)
            annotationView.image =  UIImage(named: "soccer_ball")
            annotationView.restorationIdentifier = pin.identifier
            annotationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectAnnotationView)))
            return annotationView
        }
        
        return nil
    }
    
    @objc func handleSelectAnnotationView(sender: UIGestureRecognizer)
    {
        if let uid = sender.view?.restorationIdentifier {
            gameSelected = games[uid]
            oldAddress = gameSelected?.address
            performSegue(withIdentifier: "goToGameVC", sender: nil)
        }
    }
    
    func configureLocationManager()
    {
        manager.delegate = self
        
        // use the highest level of accuracy for determining the users location
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // request permission to use location services while the app is running
        manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation:CLLocation = locations[0]
        
        var mapRegion = MKCoordinateRegion()
        mapRegion.center = userLocation.coordinate
        mapRegion.span.latitudeDelta = 0.01
        mapRegion.span.longitudeDelta = 0.01
        map.setRegion(mapRegion, animated: true)
        
        self.map.showsUserLocation = true
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // MARK: - Navigation
    @objc func handleAddButton() {
        let createGameVC = CreateGameVC()
        let navController = UINavigationController(rootViewController: createGameVC)
        
        guard let gameId = Auth.auth().currentUser?.uid else {return}
        createGameVC.game = games[gameId]
        createGameVC.map = map
        present(navController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "goToGameVC"
        {
            if let dstVC = segue.destination.childViewControllers[0] as? GameVC
            {
                dstVC.game = gameSelected
            }
        }
    }
    
    @IBAction func unwindFromGameVC(segue:UIStoryboardSegue)
    {
        // O(1): update the number players of the game selected
        if let uid = gameSelected?.identifier {
            games[uid]?.numPlayers = gameSelected?.numPlayers
        }
        
        if let srcVC = segue.source as? GameVC {
            if srcVC.game == nil {
                removeAnnotation(gameSelected)
            }
            else if srcVC.game?.address != oldAddress
            {
                if let uid = gameSelected?.identifier {
                    removeAnnotation(gameSelected)
                    games[uid] = srcVC.game
                    annotateLocation(games[uid]!)
                }
            }
        }
    
    }
}
