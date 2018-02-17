//
//  ViewController.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/29/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Friends"
        view.backgroundColor = UIColor(r: 0, g: 90, b: 0)
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "friend_requests"), style: .plain, target: self, action: #selector(handleFriendRequests))
    }
    
    @objc func handleFriendRequests()
    {
        print("friend request button pressed")
    }
}
