//
//  PointOfInterest.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 8/9/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation
import MapKit

class PointOfInterest : NSObject, MKAnnotation
{
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let placeType : PlaceType
    let rating: Int?
    init(title: String, locationName: String,  coordinate: CLLocationCoordinate2D, placeType: PlaceType, rating: Int?) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.placeType = placeType
        self.rating = rating
        super.init()
    }
}
