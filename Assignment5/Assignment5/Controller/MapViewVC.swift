//
//  MapViewVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/28/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit
import MapKit

class MapViewVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    var place : Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let placeOfInterest = place else
        {
            alertUser = "Error while loading map"
            return
        }
        
        guard let trainStop = placeOfInterest.trainStop else{
            alertUser = "Map cannot be launch Train Stop Coordinates"
            return
        }
        
        let stopLocation = CLLocation(latitude: trainStop.latitude, longitude: trainStop.longitude)
        
        centerMapOnLocation(location: stopLocation)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

}

extension MapViewVC{
    func checkLocationAuthorizationStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewVC{
    var alertUser :  String{
        get{
            preconditionFailure("You cannot read from this object")
        }
        
        set{
            let alert = UIAlertController(title: "Attention", message: newValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
}
