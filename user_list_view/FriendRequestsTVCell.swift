//
//  FriendsTVCell.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/28/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class FriendRequestsTVCell: UITableViewCell
{
    var uid: String?
    
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Decline", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "FriendRequestsTVCell")
        backgroundColor = .darkColor
        textLabel?.textColor = .superLightColor
        detailTextLabel?.textColor = .superLightColor
        
        addSubview(profileImage)
        addSubview(acceptButton)
        addSubview(declineButton)
        
        // add constraints to profileImage
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        setupAcceptButton()
        setupDeclineButton()
    }
    
    func setupAcceptButton()
    {
        let acceptButtonSize = acceptButton.sizeThatFits(CGSize.zero)
        let paddingForWidth: CGFloat = 10.0
        acceptButton.rightAnchor.constraint(equalTo: declineButton.leftAnchor, constant: -8).isActive = true
        acceptButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        acceptButton.widthAnchor.constraint(equalToConstant: acceptButtonSize.width + paddingForWidth).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupDeclineButton() {
        let declineButtonSize = acceptButton.sizeThatFits(CGSize.zero)
        let paddingForWidth: CGFloat = 10.0
        declineButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        declineButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        declineButton.widthAnchor.constraint(equalToConstant: declineButtonSize.width + paddingForWidth).isActive = true
        declineButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
