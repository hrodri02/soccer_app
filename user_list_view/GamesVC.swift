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

class GamesVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{
    @IBOutlet weak var map: MKMapView!
    
    // used to get the current user's location
    let manager = CLLocationManager()
    
    static let ref = Database.database().reference()
    
    var games: [String:Game] = [:]
    var gameIdSelected: String?
    var oldAddress: String?
    var oldCoordinate: CLLocationCoordinate2D?
    
    var timer: Timer?
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Game", style: .plain, target: self, action: #selector(handleAddButton))
        
        map.delegate = self
        
        // get the current location of a user
        configureLocationManager()
        
        observeGames()
        
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(handleReloadMap), userInfo: nil, repeats: true)
    }
    
    func observeGames()
    {
        let ref = Database.database().reference().child("games")
        ref.observe(.childAdded, with: { (snapshot) in
            let gameId = snapshot.key
            
            if let gameDict = snapshot.value as? [String:Any] {
                
                let game = Game()
                
                let numPlayers = gameDict["numPlayers"] as? String
                let address = gameDict["address"] as? String
                let startTime = gameDict["startTime"] as? String
                let durationMins = gameDict["durationMins"] as? String
                let durationHours = gameDict["durationHours"] as? String
                
                game.address = address
                game.identifier = gameId
                game.numPlayers = Int(numPlayers!)
                game.startTime = startTime
                game.durationMins = Int(durationMins!)
                game.durationHours = Int(durationHours!)
                
                if self.gameExpired(game) {
                    // remove it from the database
                    GamesVC.removeGame(gameId)
                }
                else {
                    self.games[gameId] = game
                    self.annotateLocation(game)
                }
            }
        }, withCancel: nil)
        
        ref.observe(.childChanged, with: { (snapshot) in
            
            let gameId = snapshot.key
            let oldAddress = self.games[gameId]?.address
          
            if let gameDict = snapshot.value as? [String:Any] {
                let newNumPlayers = gameDict["numPlayers"] as? String
                let newAddress = gameDict["address"] as? String
                let newStartTime = gameDict["startTime"] as? String
                let newDurationMins = gameDict["durationMins"] as? String
                let newDurationHours = gameDict["durationHours"] as? String
                
                if oldAddress != newAddress {
                    self.removeAnnotation(self.games[gameId])
                    self.games[gameId] = Game()
                    self.games[gameId]?.address = newAddress
                    self.annotateLocation(self.games[gameId]!)
                }
                
                self.games[gameId]?.identifier = gameId
                self.games[gameId]?.numPlayers = Int(newNumPlayers!)
                self.games[gameId]?.startTime = newStartTime
                self.games[gameId]?.durationMins = Int(newDurationMins!)
                self.games[gameId]?.durationHours = Int(newDurationHours!)
                
            }
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            let gameId = snapshot.key
            let game = self.games[gameId]
            
            if game?.numPlayers != 0 {
                if let gameDict = snapshot.value as? [String:AnyObject] {
                    let playersDict = gameDict["players"] as? [String:Bool]
                    
                    if let players = playersDict {
                        
                        var i = 0
                        for (playerId, _) in players {
                            let playerRef = Database.database().reference().child("users").child(playerId)
                            let gameRef = playerRef.child("games").child(gameId)
                            
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
                            
                            // decrement the games played by the current player
                            playerRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                let uid = snapshot.key
                                
                                if let playerDict = snapshot.value as? [String:AnyObject] {
                                    guard var gamesPlayed = playerDict["gamesPlayed"] as? Int else {return}
                                    gamesPlayed -= 1;
                                    
                                    var values: [String:Any] = ["gamesPlayed": gamesPlayed]
                                    
                                    // decrement the games created by the player that created the game reomved
                                    if (uid == gameId) {
                                        guard var gamesCreated = playerDict["gamesCreated"] as? Int else {return}
                                        gamesCreated -= 1
                                        values["gamesCreated"] = gamesCreated
                                     }
                                    
                                    playerRef.updateChildValues(values)
                                }
                                
                            }, withCancel: nil)
                        }
                    }
                    
                }
            }
            else {
                // removes game from map
                self.removeAnnotation(game)
                self.games[gameId] = nil
            }
         
        }, withCancel: nil)
    }
    
    @objc func handleReloadMap() {
        for (uid, soccerGame) in games {
            if gameExpired(soccerGame) {
                // removes game from database
                GamesVC.removeGame(uid)
                
                // removes game from map
                removeAnnotation(soccerGame)
                
                // removes game from dictionary
                games[uid] = nil
            }
        }
    }
    
    
    @objc func handleLogout()
    {
        do {
            try Auth.auth().signOut()
            showLoginVC()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    func showLoginVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
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
            gameIdSelected = uid
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
        mapRegion.span.latitudeDelta = 0.1
        mapRegion.span.longitudeDelta = 0.1
        map.setRegion(mapRegion, animated: true)
        
        self.map.showsUserLocation = true
        
        manager.stopUpdatingLocation()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let coorRef = Database.database().reference().child("users").child(uid).child("coordinate")
        let value = ["lat": userLocation.coordinate.latitude, "lon": userLocation.coordinate.longitude] as [String:Any]
        coorRef.updateChildValues(value)
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
                guard let gameId = gameIdSelected else {return}
                oldAddress = games[gameId]?.address
                dstVC.game = games[gameId]
            }
        }
    }
    
    @IBAction func unwindFromGameVC(segue:UIStoryboardSegue)
    {
        
    }
}
