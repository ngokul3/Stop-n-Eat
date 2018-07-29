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

        class PointOfInterest : NSObject, MKAnnotation
        {
            let title: String?
            let locationName: String
             let coordinate: CLLocationCoordinate2D
            
            init(title: String, locationName: String,  coordinate: CLLocationCoordinate2D) {
                self.title = title
                self.locationName = locationName
                self.coordinate = coordinate
           
                super.init()
            }
        }
    
    @IBOutlet weak var mapView: MKMapView!
    var points : [PointOfInterest] = []
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
        
        guard let restaurants = placeOfInterest.restaurants else{
            alertUser = "Map cannot be launch Train Stop Coordinates"
            return
        }
        
        let stopLocation = CLLocation(latitude: trainStop.latitude, longitude: trainStop.longitude)
        
        centerMapOnLocation(location: stopLocation)
        
        //ToDo Set the span based on the farthest distance from the restaurant.
        //Todo color train in red and restaurant in blue
        let span = MKCoordinateSpanMake(0.07, 0.07)
        let locationCoordinate2D = CLLocationCoordinate2D(latitude:  trainStop.latitude,longitude: trainStop.longitude)

        let region = MKCoordinateRegion(center: locationCoordinate2D, span: span)
        mapView.setRegion(region, animated: true)
        
        points.append(PointOfInterest(title: trainStop.stopName, locationName: trainStop.stopName, coordinate: CLLocationCoordinate2D(latitude: trainStop.latitude, longitude: trainStop.longitude)))

        restaurants.forEach({(restaurant) in
            points.append(PointOfInterest(title: restaurant.restaurantName, locationName: restaurant.restaurantName, coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude)))
        })
        
        print(points.count)
        mapView.addAnnotations(points)
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

extension MapViewVC: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
//                 calloutAccessoryControlTapped control: UIControl) {
//        let location = view.annotation as? PointOfInterest
//        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
//            MKLaunchOptionsDirectionsModeDriving]
//        location.mapItem().openInMaps(launchOptions: launchOptions)
//}
}
