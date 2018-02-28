//
//  ProfileVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/15/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var imageSelected: Int?
    var player: Player?
    
    var favoriteClubRecieved: String? {
        willSet {
            player?.favClubTeam = newValue
            favoriteClubTeam.text = newValue
            saveFavClubTeam()
        }
    }
    
    func saveFavClubTeam()
    {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        let userRef = ref.child("users").child(uid!)
        
        let value = ["favClubTeam": (player?.favClubTeam)!] as [String:Any]
        
        userRef.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                print("error:", error!)
                return
            }
            
            // updated user information successfully
        }
    }
    
    var positionRecieved: String? {
        willSet {
            player?.position = newValue
            position.text = newValue
            savePosition()
        }
    }
    
    func savePosition()
    {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        let userRef = ref.child("users").child(uid!)
        
        let value = ["position": (player?.position)!] as [String:Any]
        
        userRef.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                return
            }
            
            // updated user information successfully
        }
    }
    
    var experienceRecieved: String? {
        willSet {
            player?.experience = newValue
            experience.text = newValue
            saveExperience()
        }
    }
    
    func saveExperience()
    {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        let userRef = ref.child("users").child(uid!)
        
        let value = ["experience": (player?.experience)!] as [String:Any]
        
        userRef.updateChildValues(value) { (error, ref) in
            
            if error != nil {
                return
            }
            
            // updated user information successfully
        }
    }
    
    // Mark - UI components
    lazy var profileImageViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "black_play_button"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.isHidden = false
        button.addTarget(self, action: #selector(handleProfilePlayButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "black_play_button"), for: .normal)
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.white
        button.isHidden = false
        button.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var videoImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return view
    }()
    
    @objc func handleProfilePlayButton() {
        performZoomIn(imageView: profileImage)
    }
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            
            performZoomIn(imageView: imageView)
            
        }
    }
    
    var startingframe:  CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    var zoomingImageView: UIImageView!
    
    func performZoomIn(imageView: UIImageView)
    {
        startingImageView = imageView
        startingImageView?.isHidden = true
        startingframe = imageView.superview?.convert(imageView.frame, to: nil)
        
        if let frame = startingframe {
            zoomingImageView = UIImageView(frame: frame)
            
            zoomingImageView.addSubview(playButton)
            zoomingImageView.addSubview(activityIndicatorView)
            
            playButton.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
            playButton.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
            playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
            playButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            
            activityIndicatorView.centerXAnchor.constraint(equalTo: zoomingImageView.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: zoomingImageView.centerYAnchor).isActive = true
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
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
                    
                    self.zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    self.zoomingImageView.center = keyWindow.center
                    
                    self.handlePlayButton()
                    
                    
                }, completion: { (completed) in
                    
                })
                
            }
        }
    }
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    @objc func handlePlayButton() {
        if let videoURLStr = player?.videoURLStr, let url = URL(string: videoURLStr) {
            avPlayer = AVPlayer(url: url)
            
            avPlayer?.addObserver(self,
                                  forKeyPath: #keyPath(AVPlayer.rate),
                                  options: [],
                                  context: nil)
            
            avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer?.frame = zoomingImageView.bounds
            if let layer = avPlayerLayer {
                zoomingImageView.layer.addSublayer(layer)
            }
            
            avPlayer?.play()
            playButton.isHidden = true
            activityIndicatorView.startAnimating()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayer.rate) {
            
            if let rate = self.avPlayer?.rate {
                if rate == 0 {
                    avPlayerLayer?.removeFromSuperlayer()
                    activityIndicatorView.stopAnimating()
                    playButton.isHidden = false
                }
            }
        }
    }
    
    @objc func handleZoomingOut(tapGesture: UITapGestureRecognizer)
    {
        if let zoomoutImageView = tapGesture.view {
            zoomoutImageView.layer.cornerRadius = 16
            zoomoutImageView.clipsToBounds = true
            
            UIImageView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 0
                zoomoutImageView.frame = self.startingframe!
            }, completion: { (completed) in
                self.startingImageView?.isHidden = false
                zoomoutImageView.removeFromSuperview()
            })
            
            
        }
    }
    
    lazy var profileImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "soccer_player")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var backgroundImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightColor
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectBackgroundImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    @objc func handleSelectBackgroundImageView()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        imageSelected = 1
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSelectProfileImageView()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        imageSelected = 2
        
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            // we selected a video
            handleVideoSelected(with: videoURL)
        }
        else {
            // we selected an image
            playButton.isHidden = true
            handleImageSelected(for: info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelected(with videoURL: URL) {
        let filename = NSUUID().uuidString + ".mov"
        let uploadTask = Storage.storage().reference().child("videos").child(filename).putFile(from: videoURL, metadata: nil, completion: { (metadata, err) in
            if err != nil {
                print("Error uploading video to Firebase storage:", err!)
            }
            
            if let videoURLstr = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImage(for: videoURL) {
                    
                    self.profileImage.image = thumbnailImage
                    self.playButton.isHidden = false
                    
                    self.uploadToFirebase(thumbnailImage, completion: { (imageURLstr) in
                        let properties: [String:Any] = ["profileImageURL": imageURLstr, "profileImageWidth": thumbnailImage.size.width,
                                                        "profileImageHeight": thumbnailImage.size.height, "videoURLstr": videoURLstr]
                        self.sendMessage(with: properties)
                    })
                }
            }
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            self.navigationItem.title = "Dowloading Video..."
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = "Your Profile"
        }
    }
    
    private func uploadToFirebase(_ image: UIImage, completion: @escaping (_ imageURLStr: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if err != nil {
                    print("Failed to upload image:", err!)
                }
                
                if let imageURLStr = metadata?.downloadURL()?.absoluteString {
                    completion(imageURLStr)
                }
                
            })
        }
    }
    
    private func thumbnailImage(for videoURL: URL) -> UIImage? {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let err {
            print(err)
            return nil
        }
    }
    
    private func sendMessage(with properties: [String:Any]) {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref =  Database.database().reference().child("users").child(currentUID)
        
        ref.updateChildValues(properties) { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
        }
    }
    
    private func handleImageSelected(for info: [String:Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker
        {
            if imageSelected == 2
            {
                profileImage.image = selectedImage
                
                if let height = profileImage.image?.size.height, let width = profileImage.image?.size.width {
                    profileImageViewHeightAnchor?.constant = 200*(CGFloat(height)/CGFloat(width))
                    
                    profileImageViewTopAnchor?.isActive = false
                    profileImageViewTopAnchor = self.profileImage.topAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor,
                                                                                       constant: -(self.profileImageViewHeightAnchor?.constant)!/2)
                    profileImageViewTopAnchor?.isActive = true
                }
            }
            else
            {
                backgroundImageView.image = selectedImage
            }
        }
        
        // name for image that will be saved in storage
        let imageName = NSUUID().uuidString
        
        // add png to name of image and uses this as the name of image
        let storageRef = Storage.storage().reference().child("\(imageName).jpg")
        
        
        // uploading image to storage
        var typeOfImage: UIImage?
        
        if (imageSelected == 1)
        {
            typeOfImage = backgroundImageView.image
        }
        else
        {
            typeOfImage = profileImage.image
        }
        
        if let uploadData = UIImageJPEGRepresentation(typeOfImage!, 0.1)
        {
            storageRef.putData(uploadData, metadata: nil, completion:
                { (metadata, error) in
                    if error != nil
                    {
                        print(error!)
                        return
                    }
                    
                    if let imageURL = metadata?.downloadURL()?.absoluteString
                    {
                        self.registerUserImageURLIntoDatabase(imageURL: imageURL, image: typeOfImage!)
                    }
            })
        }
    }
    
    private func registerUserImageURLIntoDatabase(imageURL: String, image: UIImage)
    {
        
        let user = Auth.auth().currentUser;
        
        guard let uid = user?.uid else
        {
            return
        }
        
        let ref = Database.database().reference(fromURL: "https://pick-up-soccer.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        var values: [String: Any]
        
        if (imageSelected == 1)
        {
            
            values = ["backgroundImageURL": imageURL]
        }
        else
        {
            values = ["profileImageURL": imageURL, "profileImageWidth": image.size.width,
                      "profileImageHeight": image.size.height]
        }
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                return
            }
            
            // Saved user successfully into firebase db
        })
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let avi = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        avi.isHidden = true
        avi.translatesAutoresizingMaskIntoConstraints = false
        return avi
    }()
    
    let nameLabel: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let gamesCreatedLabel: UILabel = {
        var label = UILabel()
        label.textColor = .superLightColor
        label.text = "Games Created"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let gamesCreated: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = ""
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let gamesPlayed: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = ""
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let gamesPlayedLabel: UILabel = {
        var label = UILabel()
        label.textColor = .superLightColor
        label.text = "Games Played"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let experienceLabel: UILabel = {
        var label = UILabel()
        label.textColor = .superLightColor
        label.text = "Experience"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let experience: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = ""
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let favoriteClubTeamLabel: UILabel = {
        var label = UILabel()
        label.textColor = .superLightColor
        label.text = "Favorite Club Team"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let favoriteClubTeam: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = ""
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let positionLabel: UILabel = {
        var label = UILabel()
        label.textColor = .superLightColor
        label.text = "Position"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let position: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = ""
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let backgroundPicCV: UIView = {
        let cView = UIView()
        cView.translatesAutoresizingMaskIntoConstraints = false
        return cView
    }()
    
    lazy var backgroundPic: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let gamesPlayedCV: UIView = {
        let cView = UIView()
        cView.backgroundColor = .lightColor
        cView.translatesAutoresizingMaskIntoConstraints = false
        return cView
    }()
    
    let experienceCV: UIView = {
        let cView = UIView()
        cView.backgroundColor = .lightColor
        cView.translatesAutoresizingMaskIntoConstraints = false
        return cView
    }()
    
    let positionCV: UIView = {
        let cView = UIView()
        cView.backgroundColor = .lightColor
        cView.translatesAutoresizingMaskIntoConstraints = false
        return cView
    }()
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //getUserData()
    }
    
    /* NOTE: Everytime the profile view controller appears we read from the database */
    func getUserData()
    {
        let uid = Auth.auth().currentUser?.uid
        player = Player()
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                self.player?.gamesPlayed = (dictionary["gamesPlayed"] as? Int) ?? 0
                self.player?.gamesCreated = (dictionary["gamesCreated"] as? Int) ?? 0
                self.player?.name = dictionary["name"] as? String
                self.player?.email = dictionary["email"] as? String
                self.player?.experience = dictionary["experience"] as? String
                self.player?.favClubTeam = dictionary["favClubTeam"] as? String
                self.player?.position = dictionary["position"] as? String
                self.player?.videoURLStr = dictionary["videoURLstr"] as? String
                self.player?.profileImageWidth = dictionary["profileImageWidth"] as? NSNumber
                self.player?.profileImageHeight = dictionary["profileImageHeight"] as? NSNumber
                
                self.videoImageView.isHidden = self.player?.videoURLStr == nil
                self.profileImageViewButton.isHidden = self.player?.videoURLStr == nil
                
                if let profileImageURL = dictionary["profileImageURL"] as? String
                {
                    self.player?.profileImageURLStr = profileImageURL
                    self.profileImage.loadImageUsingCacheWithURLStr(urlStr: profileImageURL)
                    self.videoImageView.loadImageUsingCacheWithURLStr(urlStr: profileImageURL)
                    
                    if let height = self.player?.profileImageHeight, let width = self.player?.profileImageWidth  {
                        self.profileImageViewHeightAnchor?.constant = 200*(CGFloat(truncating: height)/CGFloat(truncating: width))
                        self.profileImageViewTopAnchor = self.profileImage.topAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor,
                                                                                                constant: -(self.profileImageViewHeightAnchor?.constant)!/2)
                        self.profileImage.contentMode = .scaleAspectFill
                        self.profileImageViewTopAnchor?.isActive = true
                        self.profileImage.clipsToBounds = true
                    }
                }
                else
                {
                    self.profileImage.image = UIImage(named: "soccer_player")
                    self.player?.profileImageWidth = self.profileImage.image?.size.width as NSNumber?
                    self.player?.profileImageHeight = self.profileImage.image?.size.height as NSNumber?
                    
                    self.profileImageViewHeightAnchor?.constant = self.view.frame.height/6
                    self.profileImageViewTopAnchor = self.profileImage.topAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor,
                                                                                            constant: -(self.profileImageViewHeightAnchor?.constant)!/2)
                    self.profileImage.contentMode = .scaleAspectFit
                    self.profileImageViewTopAnchor?.isActive = true
                    self.profileImage.clipsToBounds = true
                }
                
                if let backgroundImageURL = dictionary["backgroundImageURL"] as? String
                {
                    self.player?.backgroundImageURLStr = backgroundImageURL
                    self.backgroundImageView.loadImageUsingCacheWithURLStr(urlStr: backgroundImageURL)
                }
                else {
                    self.backgroundImageView.image = nil
                }
                
                DispatchQueue.main.async(execute: {
                    self.gamesPlayed.text = "\((self.player?.gamesPlayed)!)"
                    self.gamesCreated.text = "\((self.player?.gamesCreated)!)"
                    self.nameLabel.text = self.player?.name
                    self.experience.text = self.player?.experience
                    self.favoriteClubTeam.text = self.player?.favClubTeam
                    self.position.text = self.player?.position
                })
            }
            
            
        }, withCancel: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Your Profile"
        view.backgroundColor = .darkColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEditProfile))
        
        view.addSubview(backgroundImageView)
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(gamesCreated)
        view.addSubview(gamesCreatedLabel)
        view.addSubview(gamesPlayedCV)
        view.addSubview(gamesPlayed)
        view.addSubview(gamesPlayedLabel)
        view.addSubview(experienceCV)
        view.addSubview(experience)
        view.addSubview(experienceLabel)
        view.addSubview(favoriteClubTeam)
        view.addSubview(favoriteClubTeamLabel)
        view.addSubview(positionCV)
        view.addSubview(position)
        view.addSubview(positionLabel)
        profileImage.addSubview(videoImageView)
        profileImage.addSubview(profileImageViewButton)
        
        setupVideoImageView()
        setupProfilePlayButton()
        
        setupProfileImage()
        setupBackgroundImageView()
        setupNameLabel()
        
        setupGamesPlayedContainer()
        setupExperienceContainer()
        setupPositionContainer()
        
        setupGamesCreatedLabel()
        setupGamesCreated()
        setupGamesPlayedLabel()
        setupGamesPlayed()
        setupExperienceLabel()
        setupExperience()
        setupFavoriteClubTeamLabel()
        setupFavoriteClubTeam()
        setupFavoriteClubTeamLabel()
        setupPosition()
        setupPositionLabel()
        
        getUserData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let rate = avPlayer?.rate {
            if rate > 0 {
                avPlayer?.pause()
            }
        }
    }
    
    @objc func handleEditProfile()
    {
        let editProfileVC = EditProfileVC()
        let navController = UINavigationController(rootViewController: editProfileVC)
        present(navController, animated: true, completion: nil)
    }
    
    // Mark - Setup constraints for components
    
    func setupVideoImageView() {
        videoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videoImageView.topAnchor.constraint(equalTo: profileImage.topAnchor).isActive = true
        videoImageView.widthAnchor.constraint(equalTo: profileImage.widthAnchor).isActive = true
        videoImageView.heightAnchor.constraint(equalTo: profileImage.heightAnchor).isActive = true
    }
    
    func setupActivityIndicatorView() {
        activityIndicatorView.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupProfilePlayButton() {
        profileImageViewButton.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor).isActive = true
        profileImageViewButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        profileImageViewButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageViewButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    func setupBackgroundImageView()
    {
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    var profileImageViewHeightAnchor: NSLayoutConstraint?
    var profileImageViewTopAnchor: NSLayoutConstraint?
    
    func setupProfileImage()
    {
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        profileImageViewTopAnchor = profileImage.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -100)
        profileImageViewTopAnchor?.isActive = false
        
        profileImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        profileImageViewHeightAnchor = profileImage.heightAnchor.constraint(equalToConstant: 200)
        profileImageViewHeightAnchor?.isActive = true
    }
    
    func setupNameLabel()
    {
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 12).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupGamesCreatedLabel()
    {
        gamesCreatedLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        gamesCreatedLabel.topAnchor.constraint(equalTo: gamesPlayedLabel.bottomAnchor, constant: 12).isActive = true
    }
    
    func setupGamesCreated()
    {
        gamesCreated.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        gamesCreated.leftAnchor.constraint(equalTo: gamesCreatedLabel.rightAnchor).isActive = true
        gamesCreated.topAnchor.constraint(equalTo: gamesPlayedLabel.bottomAnchor, constant: 12).isActive = true
        gamesCreated.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupGamesPlayedContainer()
    {
        gamesPlayedCV.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gamesPlayedCV.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12).isActive = true
        gamesPlayedCV.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        gamesPlayedCV.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func setupGamesPlayed()
    {
        gamesPlayed.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        gamesPlayed.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12).isActive = true
        gamesPlayed.widthAnchor.constraint(equalToConstant: 25).isActive = true
        gamesPlayed.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupGamesPlayedLabel()
    {
        gamesPlayedLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        gamesPlayedLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12).isActive = true
        gamesPlayedLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        gamesPlayedLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupExperienceContainer()
    {
        experienceCV.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        experienceCV.topAnchor.constraint(equalTo: gamesCreatedLabel.bottomAnchor, constant: 12).isActive = true
        experienceCV.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        experienceCV.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func setupExperience()
    {
        experience.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        experience.topAnchor.constraint(equalTo: gamesCreatedLabel.bottomAnchor, constant: 12).isActive = true
        experience.widthAnchor.constraint(equalToConstant: 200).isActive = true
        experience.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupExperienceLabel()
    {
        experienceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        experienceLabel.topAnchor.constraint(equalTo: gamesCreatedLabel.bottomAnchor, constant: 12).isActive = true
        experienceLabel.widthAnchor.constraint(equalToConstant: 85).isActive = true
        experienceLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupFavoriteClubTeam()
    {
        favoriteClubTeam.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        favoriteClubTeam.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 12).isActive = true
        favoriteClubTeam.widthAnchor.constraint(equalToConstant: 200).isActive = true
        favoriteClubTeam.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupFavoriteClubTeamLabel()
    {
        favoriteClubTeamLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        favoriteClubTeamLabel.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 12).isActive = true
        favoriteClubTeamLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        favoriteClubTeamLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupPositionContainer()
    {
        positionCV.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        positionCV.topAnchor.constraint(equalTo: favoriteClubTeamLabel.bottomAnchor, constant: 12).isActive = true
        positionCV.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        positionCV.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    func setupPosition()
    {
        position.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        position.topAnchor.constraint(equalTo: favoriteClubTeamLabel.bottomAnchor, constant: 12).isActive = true
        position.widthAnchor.constraint(equalToConstant: 200).isActive = true
        position.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupPositionLabel()
    {
        positionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        positionLabel.topAnchor.constraint(equalTo: favoriteClubTeamLabel.bottomAnchor, constant: 12).isActive = true
        positionLabel.widthAnchor.constraint(equalToConstant: 85).isActive = true
        positionLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
}
