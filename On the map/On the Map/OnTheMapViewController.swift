//
//  OnTheMapViewController.swift
//  On the Map
//
//  Created by Joe Susnick on 9/7/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit

class OnTheMapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // TODO - Get some Logout Going
        var logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutUser")
        self.navigationItem.backBarButtonItem = logoutButton
//        self.navigationController?.navigationItem.leftBarButtonItem = logoutButton
        // Do any additional setup after loading the view.
    }

    @IBAction func logoutUser(sender: UIBarButtonItem) {
        // Logout if login was done with facebook
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // Logout if login was through udacity api
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
