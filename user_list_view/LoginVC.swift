//
//  LoginVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 7/14/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginVC: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate, GIDSignInDelegate, MessagingDelegate
{
    var player: Player?
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .lightColor
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }
        else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text  else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                self.createAlert(title: "Error", msg: "The password or email is invalid!");
                return
            }
            
            // successfully logged in user
            self.downloadUserData()
        }
        
    }
    
    func createAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func downloadUserData()
    {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        self.player?.uid = uid
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.player = Player()
            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                self.player?.name = dictionary["name"] as? String
                self.player?.email = dictionary["email"] as? String
                self.player?.profileImageURLStr = dictionary["profileImageURL"] as? String
                self.player?.backgroundImageURLStr = dictionary["backgroundImageURL"] as? String
                self.player?.experience = dictionary["experience"] as? String
                self.player?.favClubTeam = dictionary["favClubTeam"] as? String
                self.player?.position = dictionary["position"] as? String

                self.performSegue(withIdentifier: "goToGamesVC", sender: self)
            }
            
            
        }, withCancel: nil)
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else
        {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            
            // if email is not unique, then we go in here
            if  error != nil
            {
                print(error!)
                self.createAlert(title: "Error", msg: (error?.localizedDescription)!)
                return
            }
            
            guard let uid = user?.uid else {return}
            
            // successfully authenticated user
            self.player = Player()
            self.player?.name = name
            self.player?.email = email
            
            let ref = Database.database().reference()
            let usersRef = ref.child("users").child(uid)
            let userRef = Database.database().reference().child("users").child(uid)
            let values = ["name": name, "email": email]
            
            guard let token = InstanceID.instanceID().token() else {return}
            let tokenValue = [token:true]
            let notificationRef = userRef.child("deviceToken")
            notificationRef.updateChildValues(tokenValue)
            
            usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    return
                }
                
                // Saved user successfully into firebase db  
                self.performSegue(withIdentifier: "goToGamesVC", sender: self)
                
            })
            
        })
    }
    
    private func registerUserImageURLIntoDatabase(imageURL: String)
    {
        let user = Auth.auth().currentUser;
        
        guard let uid = user?.uid else
        {
            return
        }
        
        let ref = Database.database().reference(fromURL: "https://pick-up-soccer.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        let values = ["imageURL": imageURL]
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                return
            }
            
            // Saved user successfully into firebase db
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r:220, g:220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r:220, g:220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        tf.delegate = self
        return tf
    }()
    
    let homeScreenView = AppLogoView()
    
    let homeScreenBottomImage: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "soccer_field")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    let googleSigninButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleGoogleButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColor
        view.addSubview(inputsContainerView)
        view.addSubview(registerButton)
        
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(googleSigninButton)
        
        homeScreenView.title = "Pick-up Soccer"
        homeScreenView.image = UIImage(named: "soccer_ballv2")
        view.addSubview(homeScreenView)
        
        setupInputsConatinerView()
        setupRegisterButton()
        setupGoogleSigninButton()
        setupHomeScreenView()
        setupLoginRegisterSegmentedControl()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        Messaging.messaging().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        let registrationToken =  fcmToken
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userRef = Database.database().reference().child("users").child(uid)
        let tokenValue = [registrationToken:true]
        let notificationRef = userRef.child("deviceToken")
        notificationRef.updateChildValues(tokenValue)
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error != nil) {
            print("could not login into google", error!)
            return
        }
        
        print("successfuly logged into google", user)
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let err = error {
                print("Failed to create a firebase user with a Google account", err)
                return
            }
            
            
            guard let uid = user?.uid else {return}
            
            let ref = Database.database().reference().child("users").child(uid)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if !(snapshot.exists()) {
                    
                    let userRef = Database.database().reference().child("users").child(uid)
                    let values = ["name": (user?.displayName)!, "email": (user?.email)!] as [String:Any]
                    
                    guard let token = InstanceID.instanceID().token() else {return}
                    let tokenValue = [token:true]
                    let notificationRef = userRef.child("deviceToken")
                    notificationRef.updateChildValues(tokenValue)
                    
                    userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if err != nil {
                            return
                        }
                        
                        // Saved user successfully into firebase db
                        self.performSegue(withIdentifier: "goToGamesVC", sender: self)
                        
                    })
                }
                else {
                    self.performSegue(withIdentifier: "goToGamesVC", sender: self)
                }
            }, withCancel: nil)
            
        }
    }
    
    @objc func handleGoogleButton()
    {
        //GIDSignIn.sharedInstance().signIn()
    
       
    }
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        registerButton.setTitle(title, for: .normal)
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100: 150
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0: 1/3)
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            nameTextField.placeholder = ""
            nameTextField.text = ""
        }
        else {
            nameTextField.placeholder = "Name"
        }
        
        nameTextFieldHeightAnchor?.isActive = true
        
        // change height of emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    func setupLoginRegisterSegmentedControl() {
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupHomeScreenView() {
        homeScreenView.translatesAutoresizingMaskIntoConstraints = false
        homeScreenView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        homeScreenView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        homeScreenView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        homeScreenView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
    }
    
    func setupHomScreenBottomImage() {
        homeScreenBottomImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        homeScreenBottomImage.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 48).isActive = true
        homeScreenBottomImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        homeScreenBottomImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupInputsConatinerView() {
        //set x, y, width, and height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparator)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparator)
        inputsContainerView.addSubview(passwordTextField)
        
        // name constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparator.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // email constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        emailSeparator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparator.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // password constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupRegisterButton() {
        //set x, y, width, and height constraints
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        registerButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupGoogleSigninButton()
    {
        //set x, y, width, and height constraints
        googleSigninButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleSigninButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 12).isActive = true
        googleSigninButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        googleSigninButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    // MARK: - Keyboard functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleLoginRegister()
        return true
    }
    
    // hide the keyboard when the user touches outisde keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindFromGamesVC(segue:UIStoryboardSegue)
    {
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
}
