//
//  ProfileVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/15/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class MyFriendVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var player: Player? {
        didSet {
            setupProfile()
        }
    }
    
    func setupProfile() {
        if let gamesPlayedByUser = player?.gamesPlayed {
            gamesPlayed.text = "\(gamesPlayedByUser)"
        }
        else {
            gamesPlayed.text = "0"
        }
        
        if let gamesCreatedByUser = player?.gamesCreated {
            gamesCreated.text = "\(gamesCreatedByUser)"
        }
        else {
            gamesCreated.text = "0"
        }
        
        nameLabel.text = player?.name
        experience.text = player?.experience
        favoriteClubTeam.text = player?.favClubTeam
        position.text = player?.position
        
        playButton.isHidden = self.player?.videoURLStr == nil
        
        if let profileImageURL = player?.profileImageURLStr
        {
            player?.profileImageURLStr = profileImageURL
            profileImage.loadImageUsingCacheWithURLStr(urlStr: profileImageURL)
        }
        else
        {
            self.profileImage.image = UIImage(named: "soccer_player")
            self.player?.profileImageWidth = self.profileImage.image?.size.width as NSNumber?
            self.player?.profileImageHeight = self.profileImage.image?.size.height as NSNumber?
        }
        
        if let backgroundImageURL = player?.backgroundImageURLStr
        {
            self.player?.backgroundImageURLStr = backgroundImageURL
            self.backgroundImageView.loadImageUsingCacheWithURLStr(urlStr: backgroundImageURL)
        }
    }
    
    
    var profileImageViewHeightAnchor: NSLayoutConstraint?
    var profileImageViewTopAnchor: NSLayoutConstraint?
    
    // Mark - UI components
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
    
    func handleProfilePlayButton() {
        performZoomIn(imageView: profileImage)
    }
    
    func handleZoomTap(tapGesture: UITapGestureRecognizer) {
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
    func handlePlayButton() {
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
                if rate > 0 {
                    print("rate is > 0:", rate)
                }
                else {
                    print("rate is 0:", rate)
                    avPlayerLayer?.removeFromSuperlayer()
                    activityIndicatorView.stopAnimating()
                    playButton.isHidden = false
                }
            }
        }
    }
    
    func handleZoomingOut(tapGesture: UITapGestureRecognizer)
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
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let avi = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        avi.isHidden = true
        avi.translatesAutoresizingMaskIntoConstraints = false
        return avi
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
    
    override func viewWillDisappear(_ animated: Bool) {
        if let rate = avPlayer?.rate {
            if rate > 0 {
                avPlayer?.pause()
            }
        }
    }
    
    lazy var profileImage: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var backgroundImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightColor
        return imageView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Delete Friend", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    func handleDelete()
    {
        let friendshipsRef = Database.database().reference().child("friendships")
        let currentUserUid = Auth.auth().currentUser?.uid
        //let usersRef = Database.database().reference().child("users")
        let uid = player?.uid
        
        let deletedFriend = [uid! : false]
        friendshipsRef.child(currentUserUid!).updateChildValues(deletedFriend, withCompletionBlock: { (err, ref) in
            
            if err != nil
            {
                print(err!)
            }
            
            // finised updating friendships node
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    /*
    private func storeDefaultProfileImage()
    {
        // add png to name of image and uses this as the name of image
        let storageRef = Storage.storage().reference().child("defaultProfileImage.png")
        
        // uploading image to storage
        if let uploadData = UIImagePNGRepresentation(UIImage(named: "soccer_player")!)
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
                        self.registerUserImageURLIntoDatabase(imageURL: imageURL)
                    }
            })
        }
    }
    */
    
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
        label.text = "10"
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let gamesPlayed: UILabel = {
        var label = UILabel()
        label.textColor = UIColor.white
        label.text = "20"
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
        label.text = "10 years"
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
        label.text = "FC Barcelona"
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
        label.text = "Center Midfielder"
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = (player?.name)! + "'s Profile"
        view.backgroundColor = .darkColor
        
        view.addSubview(deleteButton)
        
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
        
        setupDeleteButton()
        
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
    
    func setupDeleteButton()
    {
        // add constraints to deleteButton
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.topAnchor.constraint(equalTo: positionCV.bottomAnchor, constant: 20).isActive = true
        deleteButton.widthAnchor.constraint(equalToConstant: 130).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupBackgroundImageView()
    {
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setupProfileImage()
    {
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        profileImageViewTopAnchor = profileImage.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -100)
        profileImageViewTopAnchor?.isActive = false
        
        profileImageViewHeightAnchor = profileImage.heightAnchor.constraint(equalToConstant: 200)
        profileImageViewHeightAnchor?.isActive = true
        
        if let height = player?.profileImageHeight, let width = player?.profileImageWidth  {
            
            self.profileImageViewHeightAnchor?.constant = 200*(CGFloat(height)/CGFloat(width))
            self.profileImageViewTopAnchor = self.profileImage.topAnchor.constraint(equalTo: self.backgroundImageView.bottomAnchor,
                                                                                    constant: -(self.profileImageViewHeightAnchor?.constant)!/2)
            self.profileImageViewTopAnchor?.isActive = true
            self.profileImage.clipsToBounds = true
        }
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
        gamesCreatedLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        gamesCreatedLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupGamesCreated()
    {
        gamesCreated.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        gamesCreated.topAnchor.constraint(equalTo: gamesPlayedLabel.bottomAnchor, constant: 12).isActive = true
        gamesCreated.widthAnchor.constraint(equalToConstant: 20).isActive = true
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
