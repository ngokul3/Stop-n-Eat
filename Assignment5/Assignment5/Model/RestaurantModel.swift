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
    var restaurantsFromNetwork : RestaurantArray
    var restaurantsSaved : RestaurantArray
//    var lastRestaurantNumber : Int
//    {
//        return restaurantsSaved.reduce(Int.min, {max($0, $1.itemNumber)})
//    }
//
    private init(){
        restaurantsFromNetwork = RestaurantArray()
        restaurantsSaved = RestaurantArray()
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
    func loadRestaurantFromNetwork(trainStop : TrainStop){
        
        let trainLocation = (trainStop.latitude, trainStop.longitude)
    
        guard trainLocation.0 != 0.0
            , trainLocation.1 != 0.0 else{
            preconditionFailure("Could not find Stop location")
        }

        let locationCoordinates = String(describing: trainLocation.0) + "," +  String(describing: trainLocation.1)
     
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
  
                restaurantResultArray.forEach { (restaurant) in
                    
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
                    
                    let restaurant = Restaurant(_trainStop : trainStop, _restaurantName: name, _restaurantId: id, _latitude: lat, _longitude: long, _givenRating: Int(rating))
                    
                    self.restaurantsFromNetwork.append(restaurant)
                }
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantLoadedFromNetwork), object: self))
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
     }
    
    func getRestaurantFromNetwork(fromRestaurantArray stopIndex : Int) throws ->Restaurant{
        
        guard restaurantsFromNetwork[stopIndex] else{
            throw RestaurantError.invalidRowSelection()
        }
        
        let restaurant = restaurantsFromNetwork[stopIndex]
        return restaurant
    }
    
    func getAllRestaurantsFromNetwork() throws ->RestaurantArray{
        
        guard restaurantsFromNetwork.count > 0 else{
            throw RestaurantError.zeroCount()
        }
        
       return restaurantsFromNetwork
    }
}

extension RestaurantModel{
    
    func addRestaurant(restaurant: Restaurant) throws{
      
        guard !restaurant.restaurantName.isEmpty  else{
            throw RestaurantError.invalidRestaurant()
        }
        
        restaurantsSaved.append(restaurant)
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantRefreshed), object: self))
    }
   
    func editRestaurant(restaurant: Restaurant) {
        
        restaurantsSaved.forEach({
            if($0.restaurantId == restaurant.restaurantId){
                $0.restaurantName = restaurant.restaurantName
                $0.dateVisited = restaurant.dateVisited
                $0.comments = restaurant.comments
                $0.givenRating = restaurant.givenRating
            }
        })
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantRefreshed), object: self))
   }
    
    func deleteRestaurant(restaurant: Restaurant) throws{
        
        if(restaurantsSaved.contains{$0.restaurantId == restaurant.restaurantId}){
            restaurantsSaved = restaurantsSaved.filter({($0.restaurantId != restaurant.restaurantId)})
        }
        else{
            throw RestaurantError.notAbleToDelete(name: restaurant.restaurantName)
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantRefreshed), object: self))
    }
}

class Restaurant:  NSObject, NSCoding{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(restaurantName, forKey: "restaurantId")
        aCoder.encode(restaurantName, forKey: "restaurantName")
        aCoder.encode(givenRating, forKey: "givenRating")
        aCoder.encode(myRating, forKey: "myRating")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(dateVisited, forKey : "dateVisited")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard
            let restId = aDecoder.decodeObject(forKey: "restaurantId") as? String,
            let restName = aDecoder.decodeObject(forKey: "restaurantName") as? String,
            //let restGivenRating = aDecoder.decodeInteger(forKey: "givenRating") as? Int,
           //  let restMyRating = aDecoder.decodeInteger(forKey: "myRating") as? Int,
            let restComment = aDecoder.decodeObject(forKey:"comments") as? String,
            let restDate = aDecoder.decodeObject(forKey:"dateVisited") as? Date else {
                return nil
                
        }
        
        restaurantId = restId
        restaurantName = restName
        givenRating = aDecoder.decodeInteger(forKey: "givenRating")
        myRating = aDecoder.decodeInteger(forKey: "myRating")
        comments = restComment
        dateVisited = restDate
        super.init()
    }
    
    var trainStop : TrainStop?
    var restaurantName : String = ""
    var restaurantId : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var distanceFromTrainStop : Double = 0.0
    var givenRating : Int = 0
    var myRating : Int = 0
    var isSelected : Bool = false
    var comments : String = ""
    var dateVisited : Date = Date()
    
    init(_trainStop : TrainStop, _restaurantName : String, _restaurantId : String, _latitude : Double, _longitude : Double, _givenRating : Int)
    {
        trainStop = _trainStop
        restaurantName = _restaurantName
        restaurantId = _restaurantId
        latitude = _latitude
        longitude = _longitude
        givenRating = _givenRating
    }
    
  
}
