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
    var networkDelegate : NetworkLayerListenerProtocol?
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
    
    var restaurantNetworkDelegate: NetworkLayerListenerProtocol? {
        set {
            if networkDelegate != nil && newValue != nil {
                print("warning: network delegate overwritten")
            }
            networkDelegate = newValue
        }
        get {
            return networkDelegate
        }
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
}
