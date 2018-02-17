//
//  ChatLogVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/27/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase

class ChatLogCVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var user: Player?
    {
        didSet
        {
            showUserNameInChatLogCVC(user!)
            observeMessages()
        }
    }
    
    var messages = [Message]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func observeMessages() {
        guard let currentUID = Auth.auth().currentUser?.uid, let toId = user?.uid else {
            return
        }
        
        let userMsgsRef = Database.database().reference().child("user-messages").child(currentUID).child(toId)
        userMsgsRef.observe(.childAdded, with: { (snapshot) in
            
            let msgId = snapshot.key
            let msgRef = Database.database().reference().child("messages").child(msgId)
            msgRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String:AnyObject] else {
                    return
                }
                
                let msg = Message()
                
                if dict["imageURL"] != nil {
                    msg.counter = dict["counter"] as? NSNumber
                    msg.fromId = dict["fromId"] as? String
                    msg.text = dict["text"] as? String
                    msg.timestamp = dict["timestamp"] as? NSNumber
                    msg.toId = dict["toId"] as? String
                    msg.imageURL = dict["imageURL"] as? String
                    msg.imageWidth = dict["imageWidth"] as? NSNumber
                    msg.imageHeight = dict["imageHeight"] as? NSNumber
                }
                else {
                    msg.counter = dict["counter"] as? NSNumber
                    msg.fromId = dict["fromId"] as? String
                    msg.text = dict["text"] as? String
                    msg.timestamp = dict["timestamp"] as? NSNumber
                    msg.toId = dict["toId"] as? String
                }
                
                
                self.messages.append(msg)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    self.collectionView?.scrollToBottom()
                })
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    let cellId = "cellId"
    
    lazy var inputContainerView: ChatLogInputContainerView? = {
        let containerView = ChatLogInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        containerView.chatLogCVC = self
        return containerView
    }()
    
    @objc func handleUploadViewTap()
    {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print("edited image size \(editedImage.size)")
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            print("original image size \(originalImage.size)")
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebase(selectedImage)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebase(_ image: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if err != nil {
                    print("Failed to upload image:", err!)
                }
                
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    self.sendMessage(with: imageURL, image)
                }
                
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(handleBack))
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell
        
        cell?.chatLogController = self
        
        let msg = messages[indexPath.row]
        cell?.textView.text = msg.text
        
        setupCell(cell: cell, msg: msg)
        
        if msg.imageURL != nil {
            cell?.bubbleWidthAnchor?.constant = 200
            cell?.textView.isHidden = true
        }
        else if let text = msg.text {
            cell?.bubbleWidthAnchor?.constant = estimatedFrameSize(text: text).width + 30
            cell?.textView.isHidden = false
        }
       
        
        return cell!
    }
    
    private func setupCell(cell: ChatMessageCell?, msg: Message) {
        if msg.fromId == Auth.auth().currentUser?.uid {
            cell?.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell?.textView.textColor = UIColor.white
            
            cell?.bubbleLeftAnchor?.isActive = false
            cell?.bubbleRightAnchor?.isActive = true
        }
        else {
            cell?.bubbleView.backgroundColor = ChatMessageCell.greyColor
            cell?.textView.textColor = UIColor.black
            
            cell?.bubbleRightAnchor?.isActive = false
            cell?.bubbleLeftAnchor?.isActive = true
        }
        
        if let messageImageURL = msg.imageURL {
            cell?.messageImageView.loadImageUsingCacheWithURLStr(urlStr: messageImageURL)
            cell?.messageImageView.isHidden = false
            cell?.bubbleView.backgroundColor = UIColor.clear
        }
        else {
            cell?.messageImageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let msg = messages[indexPath.row]
        
        if let imageWidth = msg.imageWidth?.floatValue, let imageHeight = msg.imageHeight?.floatValue {
            height = CGFloat(imageHeight/imageWidth*200)
        }
        else if let txt = msg.text {
            height = estimatedFrameSize(text: txt).height + 30
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameSize(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleSend()
    {
        let properties = ["text": (inputContainerView?.inputTextField.text)!] as [String:Any]
        sendMessage(with: properties)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @objc func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    private func sendMessage(with imageURL: String, _ image: UIImage) {
        let properties: [String:Any] = ["imageURL": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height, "text": "image sent"]
        sendMessage(with: properties)
    }
    
    private func sendMessage(with properties: [String:Any]) {
        let ref =  Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.uid!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        var values: [String:Any] = ["toId": toId, "fromId": fromId, "timestamp": timestamp, "counter": 2]
        
        properties.forEach { values[$0] = $1 }
        
        childRef.updateChildValues(values) { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            
            self.inputContainerView?.inputTextField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId:1])
            
            let recepientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recepientUserMessageRef.updateChildValues([messageId:1])
            
        }
    }
    
    func showUserNameInChatLogCVC(_ player: Player)
    {
        navigationItem.title = player.name
    }
    
    var startingframe:  CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomIn(imageView: UIImageView) {
        startingImageView = imageView
        startingImageView?.isHidden = true
        startingframe = imageView.superview?.convert(imageView.frame, to: nil)
        if let frame = startingframe {
            let zoomingImageView = UIImageView(frame: frame)
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomingOut)))
            zoomingImageView.backgroundColor = UIColor.red
            zoomingImageView.image = imageView.image
            
            if let keyWindow = UIApplication.shared.keyWindow {
                self.blackBackgroundView = UIView(frame: keyWindow.frame)
                self.blackBackgroundView?.backgroundColor = UIColor.black
                self.blackBackgroundView?.alpha = 0
                
                keyWindow.addSubview(self.blackBackgroundView!)
                keyWindow.addSubview(zoomingImageView)
                
                
                UIImageView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    let height = frame.height/frame.width * keyWindow.frame.width
                    
                    self.blackBackgroundView?.alpha = 1
                    self.inputContainerView?.alpha = 0
                    
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    zoomingImageView.center = keyWindow.center
                    
                    
                }, completion: { (completed) in
                    
                })
                
            }
        }
    } 
    
    @objc func handleZoomingOut(tapGesture: UITapGestureRecognizer) {
        if let zoomoutImageView = tapGesture.view {
            zoomoutImageView.layer.cornerRadius = 16
            zoomoutImageView.clipsToBounds = true
            
            UIImageView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 0
                zoomoutImageView.frame = self.startingframe!
                 self.inputContainerView?.alpha = 1
            }, completion: { (completed) in
                self.startingImageView?.isHidden = false
                zoomoutImageView.removeFromSuperview()
            })
            
          
        }
    }
}

extension UICollectionView {
    func scrollToBottom() {
        if self.numberOfSections > 1 {
            let lastSection = self.numberOfSections - 1
            self.scrollToItem(at: NSIndexPath(row: self.numberOfItems(inSection: lastSection) - 1, section: lastSection) as IndexPath, at: .bottom, animated: true)
        }
        else if numberOfItems(inSection: 0) > 0 && self.numberOfSections == 1 {
            self.scrollToItem(at: NSIndexPath(row: self.numberOfItems(inSection: 0)-1, section: 0) as IndexPath, at: .bottom, animated: true)
        }
    }
}
