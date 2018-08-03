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
        let placeType : PlaceType
        init(title: String, locationName: String,  coordinate: CLLocationCoordinate2D, placeType: PlaceType) {
            self.title = title
            self.locationName = locationName
            self.coordinate = coordinate
            self.placeType = placeType
            super.init()
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    var points : [PointOfInterest] = []
    let locationManager = CLLocationManager()
    var leg: Int = 0
    var place : Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let placeOfInterest = place else{
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
        let span = MKCoordinateSpanMake(0.07, 0.07)
        let locationCoordinate2D = CLLocationCoordinate2D(latitude:  trainStop.latitude,longitude: trainStop.longitude)

        let region = MKCoordinateRegion(center: locationCoordinate2D, span: span)
        mapView.setRegion(region, animated: true)
        
        points.append(PointOfInterest(title: trainStop.stopName, locationName: trainStop.stopName, coordinate: CLLocationCoordinate2D(latitude: trainStop.latitude, longitude: trainStop.longitude), placeType: .train))

        restaurants.forEach({(restaurant) in
            points.append(PointOfInterest(title: restaurant.restaurantName, locationName: restaurant.restaurantName, coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude, longitude: restaurant.longitude), placeType: .restaurant))
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
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Selected view \(view.annotation?.description ?? "None")")
    }
    
    
    // https://www.raywenderlich.com/166182/mapkit-tutorial-overlay-views
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineRenderer = MKPolylineRenderer(overlay: overlay)
            lineRenderer.strokeColor = UIColor(hue: CGFloat(leg) * 0.05, saturation: 0.85, brightness: 0.85, alpha: 0.75)
            lineRenderer.lineWidth = 5.0
            
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView: MKPinAnnotationView = {
            if let reusedPin = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? MKPinAnnotationView {
                print("Reusing Pin")
                return reusedPin
            }
            else {
                print("Creating new Pin")
                return MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            }
        }()
        
        let placePointOpt = annotation as? PointOfInterest
        
        guard let placePoint = placePointOpt else{
            return nil
        }
        pinView.canShowCallout = true
        pinView.pinTintColor = placePoint.placeType == .train ? UIColor.blue : UIColor.red
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("RegionWillChange: \(mapView.region)")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("RegionDidChange: \(mapView.region)")
    }
}
