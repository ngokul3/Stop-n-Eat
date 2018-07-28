//
//  RestaurantModel.swift
//  TransitBreak
//
//  Created by Gokula K Narasimhan on 7/27/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//
typealias RestaurantArray = [Restaurant]
import Foundation

class RestaurantModel: RestaurantProtocol{
  
    private static var instance: RestaurantProtocol?
    private var restaurantsFromNetwork : RestaurantArray
  //  var networkDelegate : NetworkLayerListenerProtocol?
    
    private init(){
        restaurantsFromNetwork = RestaurantArray()
    }
}

extension RestaurantModel{
    
    static func getInstance() -> RestaurantProtocol {
        if let inst = RestaurantModel.instance {
            return inst
        }
        
        let inst = RestaurantModel()
        RestaurantModel.instance = inst
        return inst
    }
    
}

extension RestaurantModel{
    
    func loadRestaurantFromNetwork(njTransitStationCoordinates locationCoordinates : String){
        let network = RestaurantNetwork()
        
        
        network.loadFromNetwork(location: locationCoordinates, term: "food", finished: {(dictionary, error) in
            print("In return from ajaxRequest: \(Thread.current)")
            
            guard let restaurantResultArray = dictionary?["businesses"] as? [ [String: AnyObject] ] else {
                print("data format error: \(dictionary?.description ?? "[Missing dictionary]")")
                return
            }
            
            OperationQueue.main.addOperation {
                print("Passing restaurant results to main operation queue: \(Thread.current)")
                
                self.restaurantsFromNetwork.removeAll()
  
                restaurantResultArray.forEach { [weak self](restaurant) in
                    
                    guard let name : String = restaurant["name"] as? String else{
                        preconditionFailure("Name not found in JSON")
                    }
                    
                    guard let id : String = restaurant["id"] as? String else{
                        preconditionFailure("Id not found in JSON")
                    }
                    
                    guard let coord : NSDictionary = restaurant["coordinates"] as? NSDictionary else{
                        preconditionFailure("latitude not found in JSON")
                    }
                    
                    guard let lat : Double = coord["latitude"] as? Double else{
                        preconditionFailure("latitude not found in JSON")
                    }

                    guard let long : Double = coord["longitude"] as? Double else{
                        preconditionFailure("longitude not found in JSON")
                    }
                    
                    guard let rating : Double = restaurant["rating"] as? Double else{
                        preconditionFailure("rating not found in JSON")
                    }
                    
                    self?.restaurantsFromNetwork.append(Restaurant(_restaurantName: name, _restaurantId: id, _latitude: lat, _longitide: long, _givenRating: Int(rating)))
                }
                //Center.post(self.filterChangedNotification)
            }
            
        } )
        
        print("Number of Records now in restaurant Array is \(restaurantsFromNetwork.count)")
    }
}
extension RestaurantModel{
    
    func addRestaurantFromNetwork(restaurantOpt: Restaurant?) {
        guard let restaurant = restaurantOpt else{
            preconditionFailure("Restaurant cannot be added")
        }
        
        restaurantsFromNetwork.append(restaurant)
        //NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.StopListFiltered), object: self))
    }
}


class Restaurant{

    var trainStopName : String = ""
    var restaurantName : String = ""
    var restaurantId : String = ""
    var latitude : Double = 0.0
    var longitide : Double = 0.0
    var distanceFromTrainStop : Double = 0.0
    var givenRating : Int = 0
    var myRating : Int = 0
    var isSelected : Bool = false
    
    init(_restaurantName : String, _restaurantId : String, _latitude : Double, _longitide : Double, _givenRating : Int)
    {
        
    }
}
