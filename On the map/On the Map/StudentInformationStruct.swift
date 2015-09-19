//
//  StudentStruct.swift
//  On the Map
//
//  Created by Joe Susnick on 9/19/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

import Foundation

struct StudentInformationStruct {
    var firstName, lastName, mapString, mediaURL: String
    var latitude, longitude: Double
    
    init(firstName: String, lastName: String, mapString: String, mediaURL: String, latitude: Double, longitude: Double) {
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
}