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
                
                self.showMap()
            }
        })
        
    }
    
    func showMap() {
        let place = MKPlacemark(coordinate: self.coords!, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: place)
        
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