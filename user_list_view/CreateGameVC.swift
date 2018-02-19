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

class CreateGameVC: UIViewController
{
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    var map: MKMapView?
    var game: Game?
    var addr: String?
    var coor: CLLocationCoordinate2D?
    var startTime: String?
    var durHours: Int?
    var durMins: Int?
    var subView: UIView?
    var player = Player()
    
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
    
    lazy var createGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Create Game", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleCreateGame), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        navigationItem.title = "Create Game"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(handleBack))
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Place"
        searchController?.searchBar.barTintColor = .lightColor
        searchController?.searchBar.tintColor = .superLightColor
        
        subView = UIView(frame: CGRect(x: 0, y: 65.0, width: view.frame.width, height: view.frame.height/8))
        subView?.addSubview((searchController?.searchBar)!)
        view.addSubview(subView!)
 
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        view.addSubview(gameDurationLabel)
        view.addSubview(timeLabel)
        view.addSubview(slider)
        view.addSubview(datePicker)
        view.addSubview(createGameButton)
        
        downloadPlayerInfo()
        setupGameDurationLabel()
        setupTimeLabel()
        setupSlider()
        setupDatePicker()
        setupCreateGameButton()
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
    
    func setupCreateGameButton()
    {
        createGameButton.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 12).isActive = true
        createGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createGameButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        createGameButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
    }
    
    func handleSliderValueOnButtonPress(_ sender: UISlider) {
        let splitSliderValue = modf(sender.value)
        durHours = Int(splitSliderValue.0)
        let decimal = splitSliderValue.1
        
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
    
    /*
    @IBAction func dissmissErrorMessage(_ sender: Any) {
        
    }
    */
    
    @objc func handleCreateGame() {
        let currentUID = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("users").child(currentUID!)
        
        handleDatePickerOnButtonPress(datePicker)
        handleSliderValueOnButtonPress(slider)
        
        if let coordinate = coor {
            if game != nil {
                map?.removeAnnotation(game!)
            }
            
            game = Game(durHours, durMins, startTime, addr, coordinate)
            game?.numPlayers = 0
            game?.identifier = currentUID
            addGameToDB(game: game!)
            
            // update the games created by current user
            player.gamesCreated! += 1
            let values = ["gamesCreated": player.gamesCreated!]
            userRef.updateChildValues(values) { (err, _) in
                if err != nil {
                    print(err!)
                }
                
                let dstVC = self.presentingViewController?.childViewControllers[0].childViewControllers[0] as? GamesVC
                dstVC?.newGame = self.game
                self.dismiss(animated: true, completion: nil)
            }
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
    
    // MARK: - Database functions
    func addGameToDB(game: Game)
    {
        let ref = Database.database().reference()
        let currentUID = Auth.auth().currentUser?.uid
        let gamesRef = ref.child("games").child(currentUID!)
        
        let values = ["startTime": "\((game.startTime)!)", "durationHours": "\((game.durationHours)!)", "durationMins": "\((game.durationMins)!)",
        "address": (game.address)!, "numPlayers": "0"] as [String:Any]
        
        gamesRef.updateChildValues(values) { (err, ref) in
            if err != nil {
                return
            }
            // saved game information into firebase db
        }
    }
    
    func downloadPlayerInfo() {
        let currentUID = Auth.auth().currentUser?.uid
        let userRef = Database.database().reference().child("users").child(currentUID!)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? [String:AnyObject] {
                if let gamesCreatedByUser = userDict["gamesCreated"] as? Int {
                    self.player.gamesCreated = gamesCreatedByUser
                }
                else {
                    self.player.gamesCreated = 0
                }
            }
        }, withCancel: nil)
    }
  
    // MARK: - Navigation
    @objc func handleBack()
    {
        dismiss(animated: true, completion: nil)
    }
}

// Handle the user's selection.
extension CreateGameVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false

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
