//
//  OnTheMapViewController.swift
//  On the Map
//
//  Created by Joe Susnick on 9/7/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import MapKit

class OnTheMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // TODO - Get some Logout Going
        var logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutUser")
        self.navigationItem.backBarButtonItem = logoutButton
        
        // Get student information
        getStudentInformationArray()
    }

    func getStudentInformationArray() {
        ParseAPIClient.sharedInstance().getStudentLocations() { (success, errorString, studentArray) in
            if success {
                println("Successfully got students")
                dispatch_async(dispatch_get_main_queue()) {
                    self.createAndAddPins(studentArray)
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

    func createAndAddPins(studentArray: [StudentInformationStruct]?) {
        // create pins
        for student in studentArray! {
            let lat = CLLocationDegrees(student.latitude as Double)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            self.annotations.append(annotation)
            self.mapView.addAnnotations(self.annotations)
        }
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
    
    // MARK - MapView Delegate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView?.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: view.annotation.subtitle!)!)
        }
    }
}
