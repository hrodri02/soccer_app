//
//  FriendsTVCell.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/28/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class SuggestedFriendsTVCell: UITableViewCell
{
    var uid: String?
    var sentFriendReq: Bool? {
        didSet {
            setupAddButton()
        }
    }
    
    var addButtonWidthAnchor: NSLayoutConstraint?
    
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 1.0
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitleColor(.superLightColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        return button
    }()
    
    func handleAdd()
    {
        if addButton.titleLabel?.text == "Add Friend" {
            let currentUID = Auth.auth().currentUser?.uid
            let usersRef = Database.database().reference().child("users")
            let pendingFriendRequestRef = usersRef.child(currentUID!).child("pendingFriendRequests")
            
            let uidOfFriendToAdd = uid
            let friendRef = usersRef.child(uidOfFriendToAdd!)
            let newFriendRequestRef = friendRef.child("newFriendRequests")
            
            addButton.setTitle("Sent Request", for: .normal)
            resizeButton()
            
            let pendingFriendRequest = [uidOfFriendToAdd!:true]
            pendingFriendRequestRef.updateChildValues(pendingFriendRequest, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    print(err!)
                }
                
                // finised updating friendships node
            })
            
            let newFriendRequest = [currentUID!:true]
            newFriendRequestRef.updateChildValues(newFriendRequest, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    print(err!)
                }
                
                // finised updating friendships node
            })
            
            // TODO: - Might need to update the Friendships node here
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "SuggestedFriendsTVCell")
        
        addSubview(profileImage)
        addSubview(addButton)
        
        // add constraints to profileImage
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        friendRequestSent()
    }
    
    func setupAddButton()
    {
        addButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        addButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        
        if sentFriendReq! {
            addButton.setTitle("Sent Request", for: .normal)
            let addButtonSize = addButton.sizeThatFits(CGSize.zero)
            let paddingForWidth: CGFloat = 10.0
            addButtonWidthAnchor = addButton.widthAnchor.constraint(equalToConstant: addButtonSize.width + paddingForWidth)
            addButtonWidthAnchor?.isActive = true
        }
        else {
            addButton.setTitle("Add Friend", for: .normal)
            addButtonWidthAnchor = addButton.widthAnchor.constraint(equalToConstant: 90)
            addButtonWidthAnchor?.isActive = true
        }
        
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func friendRequestSent() {
        let ref = Database.database().reference()
        let currentUID = Auth.auth().currentUser?.uid
        let pendingFriendRequestsRef = ref.child("users").child(currentUID!).child("pendingFriendRequests")
        
        pendingFriendRequestsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let pendingFriendRequestsDict = snapshot.value as? [String:Bool] {
                if let didSentRequest = pendingFriendRequestsDict[self.uid!] {
                    self.sentFriendReq = didSentRequest
                }
                else {
                    self.sentFriendReq = false
                }
            }
            else {
                self.sentFriendReq = false
            }
        }, withCancel: nil)
    }
    
    func resizeButton() {
        let addButtonSize = addButton.sizeThatFits(CGSize.zero)
        let paddingForWidth: CGFloat = 10.0
        addButtonWidthAnchor?.isActive = false
        addButtonWidthAnchor =  addButton.widthAnchor.constraint(equalToConstant: addButtonSize.width + paddingForWidth)
        addButtonWidthAnchor?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
