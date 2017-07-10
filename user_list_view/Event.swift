//
//  event.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/6/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class Event {
    
    //MARK: Properties
    
    var name: String
    //var photo: UIImage?
    var organizer: String
    var food: String
    var location: String
    
    //MARK: Initialization
    
    init?(name: String, organizer: String, food: String, location: String) {
        
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The organizer must not be empty
        guard !organizer.isEmpty else {
            return nil
        }
        
        // The food must not be empty
        guard !food.isEmpty else {
            return nil
        }
        
        // The location must not be empty
        guard !food.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.location = location
        self.organizer = organizer
        self.food = food
    }
}

