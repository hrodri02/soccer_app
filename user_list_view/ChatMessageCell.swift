//
//  ChatMessageCell.swift
//  user_list_view
//
//  Created by Eri on 1/23/18.
//  Copyright © 2018 Brayan Rodriguez. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell
{
    var chatLogController: ChatLogCVC?
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "Temp"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    static let blueColor = UIColor(r: 0,g: 137, b: 249)
    static let greyColor = UIColor(r: 240,g: 240, b: 240)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var messageImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return view
    }()
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            chatLogController?.performZoomIn(imageView: imageView)
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        bubbleView.addSubview(messageImageView)
        
        setupTextView()
        setupBubbleView()
        setupMessageImageView()
    }
    
    func setupBubbleView() {
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleWidthAnchor?.isActive = true
        
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setupTextView() {
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setupMessageImageView() {
        messageImageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
