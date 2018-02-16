//
//  Message.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/27/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject
{
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    var counter: NSNumber?
    var imageURL: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
