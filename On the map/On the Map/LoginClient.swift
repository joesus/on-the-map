//
//  LoginClient.swift
//  On the Map
//
//  Created by Joe Susnick on 9/7/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import Foundation

class LoginClient: NSObject {
   
    /* Shared session */
    var session: NSURLSession

    /* Authentication state */
    var userKey : String? = nil
    var sessionID : String? = nil

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> LoginClient {
        
        struct Singleton {
            static var sharedInstance = LoginClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func authenticateWithViewController(hostViewController: LoginViewController, completionHandler: (success: Bool, errorString: String?) -> ()) {
    
        // Discontinue if fields are missing
        if hostViewController.usernameField.text!.isEmpty != false || hostViewController.passwordField.text!.isEmpty != false {
            dispatch_async(dispatch_get_main_queue()) {
                let alert = UIAlertView(title: "Oops", message: "Please enter a user name and password", delegate: self, cancelButtonTitle: "Dismiss")
                alert.show()
                return
            }
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(hostViewController.usernameField.text!)\", \"password\": \"\(hostViewController.passwordField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
        
            // Handles network and other client-side errors
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Oops", message: "An error has occured", delegate: self, cancelButtonTitle: "Dismiss")
                    alert.show()
                    return
                }
            }
        
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
        
            if let responseError = parsedResult["error"] as? String {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Oops", message: responseError, delegate: self, cancelButtonTitle: "Dismiss")
                    alert.show()
                }
            }
        
            if let account = parsedResult["account"] as? [String:AnyObject] {
                if let userKey = account["key"] as? String {
                    self.userKey = userKey
                    if let session = parsedResult["session"] as? [String:AnyObject] {
                        if let sessionID = session["id"] as? String {
                            self.sessionID = sessionID
                            completionHandler(success: true, errorString: nil)
                            return
                        } else {
                            completionHandler(success: false, errorString: "Problem on our end")
                        }
                    } else {
                        completionHandler(success: false, errorString: "Problem on our end")
                    }
                } else {
                    completionHandler(success: false, errorString: "Problem on our end")
                }
            }
        }
        task.resume()
    }
    
    func signup(hostViewController: LoginViewController, completionHandler: (success: Bool, errorString: String?) -> ()) {
        
        let authorizationURL = NSURL(string: "https://www.udacity.com/account/auth#!/signin")
        let request = NSURLRequest(URL: authorizationURL!)

        let webSignupViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("WebSignupViewController") as! WebSignupViewController
        
        webSignupViewController.urlRequest = request
        webSignupViewController.completionHandler = completionHandler
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webSignupViewController, animated: false)
        
        dispatch_async(dispatch_get_main_queue(), {
            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        })


    }

    
}
