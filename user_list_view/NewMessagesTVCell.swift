//
//  NewMessagesTVCell.swift
//  user_list_view
//
//  Created by Eri on 1/22/18.
//  Copyright © 2018 Brayan Rodriguez. All rights reserved.
//

import UIKit

import Firebase

class NewMessagesTVCell: UITableViewCell
{
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0.9
        imageView.layer.borderColor = UIColor(r: 0, g: 200, b: 0).cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: .subtitle, reuseIdentifier: "NewMessageTVCell")
        backgroundColor = UIColor(r:0,g:90,b:0)
        textLabel?.textColor = UIColor(r:0,g:200,b:0)
        detailTextLabel?.textColor = UIColor(r:0,g:200,b:0)
        
        addSubview(profileImage)
        
        
        // add constraints to profileImage
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
