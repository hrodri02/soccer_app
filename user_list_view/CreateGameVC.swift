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
    @IBOutlet weak var setGameDetailsLabel: UILabel!
    @IBOutlet weak var gameDurationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var createGameButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
    var map: MKMapView?
    var game: Game?
    var addr: String?
    var coor: CLLocationCoordinate2D?
    var startTime: String?
    var durHours: Int?
    var durMins: Int?
    var player = Player()
    
    func setupLabels()
    {
        //setGameDetailsLabel.textColor = UIColor(r:0, g: 200, b:0)
        gameDurationLabel.textColor = UIColor.white
        timeLabel.textColor = .superLightColor
        timeLabel.text = "0 h 30 m"
    }
    
    func setupCreateButton()
    {
        createGameButton.setTitleColor(.superLightColor, for: .normal)
        createGameButton.backgroundColor = .lightColor
        createGameButton.layer.cornerRadius = 10
    }
    
    func setupSlider()
    {
        slider.minimumTrackTintColor = .superLightColor
        slider.value = 0
    }
    
    func setupDatePicker()
    {
        datePicker.setValue(UIColor.white, forKey: "textColor")
        datePicker.datePickerMode = UIDatePickerMode.time  // show the time in date picker only
        
        // set the minimum date to today's date
        let date = Date()
        datePicker.minuteInterval = 15
        datePicker.minimumDate = date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        navigationItem.title = "Create Game"
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Place"
        searchController?.searchBar.barTintColor = .lightColor
        searchController?.searchBar.tintColor = .superLightColor
        
        let subView = UIView(frame: CGRect(x: 0, y: 65.0, width: view.frame.width, height: view.frame.height/4))
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
 
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        downloadPlayerInfo()
        setupLabels()
        setupSlider()
        setupCreateButton()
        setupDatePicker()
    }
    
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
    
    @IBAction func sliderChange(_ sender: Any)
    {
        let splitSliderValue = modf(slider.value)
        var hours = Int(splitSliderValue.0)
        let decimal = splitSliderValue.1
        
        print(slider.value)
        
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
    
    @IBAction func dissmissErrorMessage(_ sender: Any) {
        
    }
    
    @IBAction func createGameButtonPressed(_ sender: Any) {
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
        }
        else {
            createAlert(title: "Error", msg: "Please enter a location")
        }
        
        // update the games created by current user
        player.gamesCreated! += 1
        let values = ["gamesCreated": player.gamesCreated!]
        userRef.updateChildValues(values) { (err, _) in
            if err != nil {
                print(err!)
            }
        }
    }
    
    func createAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func addGameToDB(game: Game)
    {
        let ref = Database.database().reference()
        let currentUID = Auth.auth().currentUser?.uid
        let gamesRef = ref.child("games").child(currentUID!)
        
        let values = ["startTime": "\(game.startTime!)", "durationHours": "\(game.durationHours!)", "durationMins": "\(game.durationMins!)",
            "address": game.address, "numPlayers": "0"]
        
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
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "unwindFromCreate"
        {
            if game != nil {
                return true
            }
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "unwindFromCreate"
        {
            let destVC = segue.destination as? GamesVC
            destVC?.newGame = self.game
        }
    }
}

// Handle the user's selection.
extension CreateGameVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false

        searchController?.searchBar.text = place.name
        addr = place.name
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(place.formattedAddress!) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            
            if let placemark = placemarks?.first
            {
                self.coor = (placemark.location?.coordinate)!
            }
        }
        
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
