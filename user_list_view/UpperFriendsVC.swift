//
//  upperFriendsVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/30/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class UpperFriendsVC: UIViewController {
    
    let suggestedFriendsLabel: UILabel = {
        let label = UILabel()
        label.text = "Suggested Friends"
        label.textColor = .superLightColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        view.addSubview(suggestedFriendsLabel)
        setupSuggestedFriendsLabel()
        
    }
    
    func setupSuggestedFriendsLabel()
    {
        suggestedFriendsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 17).isActive = true
        suggestedFriendsLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        suggestedFriendsLabel.widthAnchor.constraint(equalToConstant: 50)
        suggestedFriendsLabel.heightAnchor.constraint(equalToConstant: 21)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
