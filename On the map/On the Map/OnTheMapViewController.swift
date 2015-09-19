//
//  OnTheMapViewController.swift
//  On the Map
//
//  Created by Joe Susnick on 9/7/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import MapKit

class OnTheMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // TODO - Get some Logout Going
        var logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutUser")
        self.navigationItem.backBarButtonItem = logoutButton
        
        getStudentInformationArray()
    }

    func getStudentInformationArray() {
        ParseAPIClient.sharedInstance().getStudentLocations() { (success, errorString, studentArray) in
            if success {
                println("Successfully got students")
            } else {
                self.displayError(errorString)
            }
        }

    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                println(errorString)
            }
        })
    }

    @IBAction func logoutUser(sender: UIBarButtonItem) {
        // Logout if login was done with facebook
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // Logout if login was through udacity api
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
