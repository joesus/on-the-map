//
//  OnTheMapListViewController.swift
//  On the Map
//
//  Created by A658308 on 9/22/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import Foundation

class OnTheMapListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var students: [StudentInformationStruct]?

    override func viewDidLoad() {
        // get student data
        getStudentInformationArray()
    }
    
    func getStudentInformationArray() {
        ParseAPIClient.sharedInstance().getStudentLocations() { (success, errorString, studentArray) in
            if success {
                println("Successfully got students")
                dispatch_async(dispatch_get_main_queue()) {
                    self.students = studentArray
                    self.tableView.reloadData()
                }
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
    
    // Mark: - TableView Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let studentArray = students {
            return count(studentArray)
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        if let studentArray = students {
            var student = studentArray[indexPath.row]
            var infoButton = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
            infoButton.frame = CGRectMake(3,8,30, 30);
            cell.accessoryType = UITableViewCellAccessoryType.DetailButton
            cell.textLabel!.text = "\(student.firstName) \(student.lastName)"
            cell.detailTextLabel!.text = student.mapString
        }
        return cell
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        
        if let studentArray = students {
            app.openURL(NSURL(string: studentArray[indexPath.row].mediaURL)!)
        }
    }
    
    // Mark - UI Overrides
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func logoutUser(sender: UIBarButtonItem) {
        // Logout if login was done with facebook
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // Logout if login was through udacity api
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
