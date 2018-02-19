//
//  CreateVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/20/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import GoogleMaps
import GooglePlaces

class EditGameVC: UIViewController
{
    // MARK: - member variables
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    var game: Game?
    var addr: String?
    var coor: CLLocationCoordinate2D?
    var startTime: String?
    var durHours: Int?
    var durMins: Int?
    var subView: UIView?
    static let ref = Database.database().reference()
    private static var gameId: String?
    static var playersOfGame: [String:Bool]? {
        didSet {
            removeGameFromGamesList()
        }
    }
    
    var gamesUserIsPartOf = [(Date,Date)]()
    
    // MARK: - UI components
    let gameDurationLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "Game Duration"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let timeLabel: UILabel = {
        var label = UILabel()
        label.textColor = .superLightColor
        label.text = "0 h 30 m"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let slider: UISlider = {
        var slider = UISlider()
        slider.minimumTrackTintColor = .superLightColor
        slider.value = 0
        slider.maximumValue = 4.0
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    @objc func handleSliderChange()
    {
        let splitSliderValue = modf(slider.value)
        var hours = Int(splitSliderValue.0)
        let decimal = splitSliderValue.1
        
        var mins: Int = 0
        
        if (decimal < 0.5) {
            if hours != 4 {
                mins =  30
            }
        }
        else {
            hours += 1
            mins = 0
        }
        
        timeLabel.text = "\(hours) h \(mins) m"
    }
    
    lazy var deleteGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Delete Game", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    lazy var datePicker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.setValue(UIColor.white, forKey: "textColor")
        picker.datePickerMode = UIDatePickerMode.time  // show the time in date picker only
        picker.minuteInterval = 15  // set the minimum date to today's date
        picker.minimumDate = Date()
        return picker
    }()
    
    // MARK: - viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        navigationItem.title = "Edit Game"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(handleBack))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        
        getGamesUserIsPartOf()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Place"
        
        subView = UIView(frame: CGRect(x: 0, y: 65.0, width: view.frame.width, height: view.frame.height/8))
        subView?.addSubview((searchController?.searchBar)!)
        view.addSubview(subView!)
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        searchController?.searchBar.barTintColor = .lightColor
        searchController?.searchBar.tintColor = .superLightColor
        
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        view.addSubview(gameDurationLabel)
        view.addSubview(timeLabel)
        view.addSubview(slider)
        view.addSubview(datePicker)
        view.addSubview(deleteGameButton)
        
        setupGameDurationLabel()
        setupTimeLabel()
        setupSlider()
        setupDatePicker()
        setupDeleteGameButton()
    }
    
    // MARK: - setup constraints for UI components
    func setupGameDurationLabel()
    {
        gameDurationLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 12).isActive = true
        gameDurationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        gameDurationLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        gameDurationLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupTimeLabel()
    {
        timeLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 12).isActive = true
        timeLabel.leftAnchor.constraint(equalTo: gameDurationLabel.rightAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }

    func setupSlider()
    {
        slider.topAnchor.constraint(equalTo: gameDurationLabel.bottomAnchor, constant: 12).isActive = true
        slider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        slider.widthAnchor.constraint(equalToConstant: view.frame.width - 20).isActive = true
        slider.heightAnchor.constraint(equalToConstant: slider.frame.height).isActive = true
    }
    
    func setupDatePicker()
    {
        datePicker.topAnchor.constraint(equalTo: (subView?.bottomAnchor)!).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: view.frame.height/4).isActive = true
    }
    
    func setupDeleteGameButton()
    {
        deleteGameButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 12).isActive = true
        deleteGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteGameButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        deleteGameButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - Button press functions
    func handleDatePickerOnButtonPress(_ sender: UIDatePicker) {
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        startTime = selectedDate
        
        if startTime == nil {
            print("start time is nil")
        }
    }
    
    func handleSliderValueOnButtonPress(_ sender: UISlider) {
        let splitSliderValue = modf(sender.value)
        durHours = Int(splitSliderValue.0)
        let decimal = splitSliderValue.1
        
        print(slider.value)
        durMins = 0
        
        if (decimal < 0.5) {
            if durHours != 4 {
                durMins =  30
            }
        }
        else {
            durHours! += 1
            durMins = 0
        }
        
        if durMins == nil || durHours == nil {
            print("duration hours or minutes is nil")
        }
    }
    
    // MARK: - Database functions
    
    func addGameToDB(game: Game)
    {
        let ref = Database.database().reference()
        let currentUID = Auth.auth().currentUser?.uid
        let gamesRef = ref.child("games").child(currentUID!)
        
        let values = ["startTime": "\(game.startTime!)", "durationHours": "\(game.durationHours!)", "durationMins": "\(game.durationMins!)",
        "address": (game.address)!] as [String:Any]
        
        gamesRef.updateChildValues(values) { (err, ref) in
            if err != nil {
                return
            }
            // saved game information into firebase db
        }
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
            
            for (player, isPartOfGame) in players {
                if isPartOfGame {
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
    }
    
    // MARK: - Navigation
    @objc func handleBack()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDelete()
    {
        EditGameVC.gameId = (game?.identifier)!
        EditGameVC.getPlayersList((game?.identifier)!)
    
        if let presenter = presentingViewController?.childViewControllers[0] as? GameVC {
            presenter.game = nil
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone()
    {
        // get start time of game
        handleDatePickerOnButtonPress(datePicker)
        
        // get duration of game
        handleSliderValueOnButtonPress(slider)
        
        if let coordinate = coor {
            game?.address = addr
            game?.durationHours = durHours
            game?.durationMins = durMins
            game?.startTime = startTime
            game?.coordinate = coordinate
            
            // make sure the edited game doesn't conflit with the other games the user is a part of
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
            let startDateOfEditedGame = dateFormatter.date(from: startTime!)
            
            let gregorian = Calendar(identifier: .gregorian)
            var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDateOfEditedGame!)
            components.hour = (components.hour)! + (durHours)!
            components.minute = (components.minute)! + (durMins)!
            let expirationDateOfEditedGame = gregorian.date(from: components)!
            
            for (startDate, endDate) in gamesUserIsPartOf {
                if (startDate <= startDateOfEditedGame! && startDateOfEditedGame! < endDate) ||
                    (startDate < expirationDateOfEditedGame && expirationDateOfEditedGame <= endDate) {
                    self.createAlert(title: "Error", msg: "There is a time conflict with another game you are apart of")
                    return
                }
            }
                
            addGameToDB(game: game!)
            if let presenter = presentingViewController?.childViewControllers[0] as? GameVC {
                presenter.game = game
            }
            dismiss(animated: true, completion: nil)
        
        }
        else {
            createAlert(title: "Error", msg: "Please enter a location")
        }
    }
    
    func createAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func getGamesUserIsPartOf() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(currentUID).child("games")
        
        ref.observe(.childAdded, with: { (snapshot) in
            let gameId = snapshot.key
            guard let isPartOfGame = snapshot.value as? Bool else {
                return
            }
            
            if gameId == currentUID {
                return
            }
            
            if isPartOfGame {
                // get start date and and duration of game
                let gameRef = Database.database().reference().child("games").child(gameId)
                gameRef.observe(.value, with: { (snapshot) in
                    if let gameDict = snapshot.value as? [String:AnyObject] {
                        let startTime = gameDict["startTime"] as? String
                        let durationHours = gameDict["durationHours"] as? String
                        let durHours = Int(durationHours!)
                        let durationMins = gameDict["durationMins"] as? String
                        let durMins = Int(durationMins!)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm a"
                        
                        let startDate = dateFormatter.date(from: (startTime)!)
                        
                        let gregorian = Calendar(identifier: .gregorian)
                        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate!)
                        components.hour = (components.hour)! + (durHours)!
                        components.minute = (components.minute)! + (durMins)!
                        let expirationDate = gregorian.date(from: components)!
                        
                        self.gamesUserIsPartOf.append((startDate!, expirationDate))
                    }
                    
                }, withCancel: nil)
            }
            
        }, withCancel: nil)
    }
}

// Handle the user's selection.
extension EditGameVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        // Do something with the selected place.
        
        searchController?.searchBar.text = place.name
        addr = place.name
        coor = place.coordinate
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


