//
//  User.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/23/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class Player: NSObject
{
    var name: String?
    var email: String?
    var profileImageURLStr: String?
    var profileImageWidth: NSNumber?
    var profileImageHeight: NSNumber?
    var videoURLStr: String?
    var backgroundImageWidth: NSNumber?
    var backgroundImageHeight: NSNumber?
    var backgroundImageURLStr: String?
    var uid: String?
    var gamesPlayed: Int?
    var gamesCreated: Int?
    var experience: String?
    var favClubTeam: String?
    var position: String?
}
