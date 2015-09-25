//
//  ParseAPIClient.swift
//  On the Map
//
//  Created by Joe Susnick on 9/19/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import Foundation

class ParseAPIClient: NSObject {
    
    let PARSE_APPLICATION_ID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    let REST_API_Key = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    let STUDENT_API_BASE_URL_STRING = "https://api.parse.com/1/classes/StudentLocation"
    
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseAPIClient {
        
        struct Singleton {
            static var sharedInstance = ParseAPIClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?, studentArray: [StudentInformationStruct]?) -> ()) {
        var studentInformationArray: [StudentInformationStruct] = []
        let request = NSMutableURLRequest(URL: NSURL(string: STUDENT_API_BASE_URL_STRING + "?limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            // Handles network and other client-side errors
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Oops", message: "An error has occured", delegate: self, cancelButtonTitle: "Dismiss")
                    alert.show()
                    return
                }
            }
            
            let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
            
            if let studentsArray = parsedResult["results"] as? [[String:AnyObject]] {
                // iterate through the dictionaries to create studentInformationArray
                for student in studentsArray {
                    studentInformationArray.append(
                        StudentInformationStruct(
                            firstName: student["firstName"] as! String,
                            lastName: student["lastName"] as! String,
                            mapString: student["mapString"] as! String,
                            mediaURL: student["mediaURL"] as! String,
                            latitude: student["latitude"] as! Double,
                            longitude: student["longitude"] as! Double)
                    )
                }
                completionHandler(success: true, errorString: nil, studentArray: studentInformationArray)
            } else {
                completionHandler(success: false, errorString: "Something went wrong", studentArray: nil)
            }
        }
        task.resume()
    }
    
    func postStudentLocations(studentInfo: StudentInformationStruct!, completionHandler: (success: Bool, errorString: String?) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: STUDENT_API_BASE_URL_STRING)!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"\(studentInfo.firstName)\", \"lastName\": \"\(studentInfo.lastName)\",\"mapString\": \"\(studentInfo.mapString)\", \"mediaURL\": \"\(studentInfo.mediaURL)\",\"latitude\": \(studentInfo.latitude), \"longitude\": \(studentInfo.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Oops", message: "An error has occured", delegate: self, cancelButtonTitle: "Dismiss")
                    alert.show()
                    return
                }
            } else {
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }
}