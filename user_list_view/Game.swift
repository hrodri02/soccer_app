//
//  Game.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/25/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import MapKit
import CoreLocation

class Game: NSObject, MKAnnotation
{
    var durationHours: Int?
    var durationMins: Int?
    var startTime: String?
    var address: String?
    var numPlayers: Int?
    var identifier: String?
    var coordinate: CLLocationCoordinate2D
    
    var title: String? {
        return address
    }
    
    override init()
    {
        self.coordinate = CLLocationCoordinate2D()
        super.init()
    }
    
    init(_ durationHours: Int?, _ durationMins: Int?,  _ startTime: String?, _ address: String?, _ coordinate: CLLocationCoordinate2D)
    {
        self.durationHours = durationHours
        self.durationMins = durationMins
        self.startTime = startTime
        self.address = address
        self.coordinate = coordinate
        super.init()
    }
    
    deinit {
        print(identifier! + " is being deinitialzed")
    }
}
