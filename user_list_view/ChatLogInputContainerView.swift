//
//  ChatLogCVCView.swift
//  user_list_view
//
//  Created by Eri on 2/5/18.
//  Copyright © 2018 Brayan Rodriguez. All rights reserved.
//

import UIKit

class ChatLogInputContainerView: UIView, UITextFieldDelegate
{
    var chatLogCVC: ChatLogCVC? {
        didSet {
            sendButton.addTarget(chatLogCVC, action: #selector(ChatLogCVC.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogCVC, action: #selector(ChatLogCVC.handleUploadViewTap)))
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    let uploadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "upload_image_icon")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let separatorLineView: UIView = {
        var lineView = UIView()
        lineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        return lineView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubviews()
        setupConstraintsForComponents()
    }
    
    func addSubviews()
    {
        addSubview(uploadImageView)
        addSubview(sendButton)
        addSubview(inputTextField)
        addSubview(separatorLineView)
    }
    
    func setupConstraintsForComponents() {
        setupUploadImageView()
        setupSendButton()
        setupInputTextField()
        setupSeparatorLineView()
    }
    
    func setupUploadImageView()
    {
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func setupSendButton()
    {
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func setupInputTextField() {
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func setupSeparatorLineView()
    {
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogCVC?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
