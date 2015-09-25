//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by A658308 on 9/24/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class InformationPostingViewController: UIViewController {
    
    private weak var tableVC: InformationPostingTableViewController?
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerView: UIView!
    var student: StudentInformationStruct?
    var coords: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start out with the second stage of the flow hidden
        submitButton.hidden = true
        urlTextView.hidden = true
        mapView.hidden = true
    }
    
    @IBAction func endEditing(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func didPressCancel(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func geocodeInput(sender: UIButton) {
    
        let geoCoder = CLGeocoder()
        let geocodeString = tableVC?.textField.text
        
        geoCoder.geocodeAddressString(geocodeString, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) in
            if error != nil {
                println("Geocode failed with error: \(error.localizedDescription)")
            } else if placemarks.count > 0 {
                let placemark = placemarks[0] as! CLPlacemark
                let location = placemark.location
                self.coords = location.coordinate
                self.centerMapOnLocation(location)
                self.createAndAddAnnotation(geocodeString!, location: location)
                self.showMap()
            }
        })
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func createAndAddAnnotation(geocodeString: String, location: CLLocation) {
        student = StudentInformationStruct(firstName: "Joe", lastName: "Susnick", mapString: geocodeString, mediaURL: self.urlTextView.text, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "\(student!.firstName) \(student!.lastName)"
        annotation.subtitle = student!.mediaURL
        
        self.mapView.addAnnotation(annotation)
    }
    
    func showMap() {
        // hide the container vc
        self.containerView.hidden = true
        // unhide the rest
        self.submitButton.hidden = false
        self.urlTextView.hidden = false
        self.mapView.hidden = false
        // change the background
        self.view.backgroundColor = UIColor(red: 63/255, green: 116/255, blue: 167/255, alpha: 1.0)
        self.cancelButton.titleLabel?.textColor = UIColor.whiteColor()
    }
    
    @IBAction func submitStudentInformation(sender: UIButton) {
        student?.mediaURL = self.urlTextView.text
        ParseAPIClient.sharedInstance().postStudentLocations(student!, completionHandler: { (success, errorString) -> () in
            if success == true {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    if let errorString = errorString {
                        println(errorString)
                    }
                })
            }
        })
    }
    
    // embedding in a container is considered a segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? InformationPostingTableViewController {
            tableVC = destination
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}