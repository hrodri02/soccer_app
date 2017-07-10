//
//  ViewController.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/6/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var dataFromTable : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(dataFromTable!) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
            }
            
            // Use your location
            let alt = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            GMSServices.provideAPIKey("AIzaSyD-FWhV_HfCJx413cdsJOUwFrI4w-PBJ8o")
            let camera = GMSCameraPosition.camera(withLatitude: alt, longitude: lon, zoom: 12)
            let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            self.view = mapView
            
            let currentLocation = CLLocationCoordinate2DMake(alt, lon)
            let marker = GMSMarker(position: currentLocation)
            marker.title = self.dataFromTable!
            marker.map = mapView
        }
    }
}
