//
//  EditProfileVC.swift
//  user_list_view
//
//  Created by Eri on 10/19/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class Position: NSObject {
    let positionName: String
    
    init(pos: String)
    {
        self.positionName = pos
    }
}

class Experience: NSObject {
    let years: String
    
    init(numYears: String)
    {
        self.years = numYears
    }
}

class EditProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    var positionSelected: String?
    var experienceSelected: String?
    
    let positionCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .lightColor
        cv.alpha = 0
        return cv
    }()
    
    let experienceCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .lightColor
        cv.alpha = 0
        return cv
    }()
    
    let cellIdPos = "cellIdPos"
    let cellIdExp = "cellIdExp"
    
    let positions: [Position] = {
        return [Position(pos: "forward"), Position(pos: "striker"), Position(pos: "right midfielder"), Position(pos: "defensive midfielder"),
                Position(pos: "left midfielder"), Position(pos: "left back"), Position(pos: "stopper"), Position(pos: "right back"),
                Position(pos: "goalkeeper")]
    }()
    
    let experience: [Experience] = {
        return [Experience(numYears: "0 - 5 years"), Experience(numYears: "6 - 10 years"), Experience(numYears: "11 - 15 years"),
                Experience(numYears: "16 - 20 years"), Experience(numYears: "21 or more years")]
    }()
    
    lazy var positionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Position", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handlePositionButton), for: .touchUpInside)
        return button
    }()
    
    lazy var experienceButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Experience", for: .normal)
        button.setTitleColor(.superLightColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleExperienceButton), for: .touchUpInside)
        return button
    }()
    
    let favoriteClubTeamLabel: UILabel = {
        var label = UILabel()
        label.textColor = .superLightColor
        label.text = "Favorite Club"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let favoriteClubTeamTextField: UITextField = {
        var textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var updateProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Update Profile", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleUpdateProfile), for: .touchUpInside)
        return button
    }()
    
    func handleUpdateProfile()
    {
        let profileVC = presentingViewController?.childViewControllers[1].childViewControllers[0] as? ProfileVC
        
        if let teamSelected = favoriteClubTeamTextField.text {
            profileVC?.favoriteClubRecieved = teamSelected
        }
        
        if let posSelected = positionSelected {
            profileVC?.positionRecieved = posSelected
        }
        
        if let expSelected = experienceSelected {
            profileVC?.experienceRecieved = expSelected
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    let blackView = UIView()
    
    func handlePositionButton()
    {
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        view.addSubview(blackView)
        blackView.frame = view.frame
        blackView.alpha = 0
        
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        // animate black view onto the screeen
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0.5
        }
        
        positionCV.frame = CGRect(x: 30, y: positionButton.frame.maxY, width: view.frame.width - 60, height: 200)
        view.addSubview(positionCV)
        positionCV.alpha = 0
        positionCV.backgroundColor = .lightColor
        
        // animate collection view onto the screen
        UIView.animate(withDuration: 0.5)
        {
            self.positionCV.alpha = 1
            
            self.positionCV.frame = CGRect(x: 30, y: self.positionButton.frame.maxY, width: self.view.frame.width - 60, height: 200)
        }
    }
    
    func handleExperienceButton()
    {
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        view.addSubview(blackView)
        blackView.frame = view.frame
        blackView.alpha = 0
        
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        // animate black view onto the screeen
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0.5
        }
        
        view.addSubview(experienceCV)
        experienceCV.alpha = 0
        experienceCV.backgroundColor = .lightColor
        
        // animate collection view onto the screen
        UIView.animate(withDuration: 0.5) {
            self.experienceCV.alpha = 1
            self.experienceCV.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
            self.experienceCV.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
            self.experienceCV.topAnchor.constraint(equalTo: self.experienceButton.bottomAnchor).isActive = true
            self.experienceCV.heightAnchor.constraint(equalToConstant: 200).isActive = true
        }
    }
    
    func handleDismiss()
    {
        UIView.animate(withDuration: 0.5) { 
            self.blackView.alpha = 0
            self.positionCV.alpha = 0
            self.experienceCV.alpha = 0
        }
    }
    
    func handleBack()
    {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(handleBack))
        
        view.backgroundColor = .darkColor
        
        positionCV.dataSource = self
        positionCV.delegate = self
        experienceCV.dataSource = self
        experienceCV.delegate = self
        
        positionCV.register(PositionCell.self, forCellWithReuseIdentifier: cellIdPos)
        experienceCV.register(ExperienceCell.self, forCellWithReuseIdentifier: cellIdExp)
        
        view.addSubview(positionButton)
        view.addSubview(experienceButton)
        view.addSubview(favoriteClubTeamLabel)
        view.addSubview(favoriteClubTeamTextField)
        view.addSubview(updateProfileButton)
        
        setupFavoriteClubTeamLabel()
        setupFavoriteClubTeamTextField()
        setupPositionButton()
        setupExperienceButton()
        setupUpdateProfileButton()
    }
    
    func setupCollectionView()
    {
        
        positionCV.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        positionCV.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        positionCV.topAnchor.constraint(equalTo: positionButton.bottomAnchor).isActive = true
        positionCV.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    func setupFavoriteClubTeamLabel()
    {
        favoriteClubTeamLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        favoriteClubTeamLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 12).isActive = true
        favoriteClubTeamLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        favoriteClubTeamLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupFavoriteClubTeamTextField()
    {
        favoriteClubTeamTextField.leftAnchor.constraint(equalTo: favoriteClubTeamLabel.rightAnchor, constant: 20).isActive = true
        favoriteClubTeamTextField.rightAnchor.constraint(equalTo: positionButton.rightAnchor).isActive = true
        favoriteClubTeamTextField.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 12).isActive = true
        favoriteClubTeamTextField.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupPositionButton()
    {
        positionButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        positionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        positionButton.topAnchor.constraint(equalTo: experienceButton.bottomAnchor, constant: 12).isActive = true
        positionButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupExperienceButton()
    {
        experienceButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        experienceButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        experienceButton.topAnchor.constraint(equalTo: favoriteClubTeamLabel.bottomAnchor, constant: 12).isActive = true
        experienceButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }
    
    func setupUpdateProfileButton()
    {
        updateProfileButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        updateProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateProfileButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        updateProfileButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.positionCV
        {
            return positions.count
        }
        
        return experience.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.positionCV {
            let cellPos = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdPos, for: indexPath) as! PositionCell
            cellPos.pos = positions[indexPath.item]
            return cellPos
        }
        else
        {
            let cellExp = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdExp, for: indexPath) as! ExperienceCell
            cellExp.exp = experience[indexPath.item]
            return cellExp
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.positionCV
        {
            positionSelected = positions[indexPath.item].positionName
            handleDismiss()
        }
        else
        {
            experienceSelected = experience[indexPath.item].years
            handleDismiss()
        }
    }
}
