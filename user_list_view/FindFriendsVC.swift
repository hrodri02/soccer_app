//
//  FindFriendsVC.swift
//  user_list_view
//
//  Created by Brayan Rodriguez  on 8/15/17.
//  Copyright © 2017 Brayan Rodriguez. All rights reserved.
//

import UIKit

class FindFriendsVC: UIViewController
{
    let searchTextField: UITextField =
    {
        let textField = UITextField()
        
        textField.placeholder = "Search"
        textField.textAlignment = .center
        textField.textColor = UIColor(r:0,g:200,b:0)
        textField.layer.borderColor = UIColor(r:0,g:200,b:0).cgColor
        textField.layer.borderWidth = 1.0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r:0, g: 90, b: 0)
        view.addSubview(searchTextField)
        setupSearchTextField()
    }
    
    func setupSearchTextField()
    {
        searchTextField.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchTextField.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchTextField.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        searchTextField.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
