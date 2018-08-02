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
    private var searchedRestaurants = [String : RestaurantArray]()
    private lazy var networkModel = {
        return AppDel.networkModel
    }()
    var restaurantsFromNetwork : RestaurantArray
    var restaurantsSaved : RestaurantArray
 
    
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
    
    static func getTotalFavoriteCount()->Int{
        return getInstance().restaurantsSaved.count
    }
}

extension RestaurantModel{
    func loadRestaurantFromNetwork(trainStop : TrainStop) throws{
        
        if let restaurantArray = searchedRestaurants[trainStop.stopName] {
            restaurantsFromNetwork = restaurantArray
            return
        }
        
        let trainLocation = (trainStop.latitude, trainStop.longitude)
    
        guard trainLocation.0 != 0.0
            , trainLocation.1 != 0.0 else{
            preconditionFailure("Could not find Stop location")
        }

        let locationCoordinates = String(describing: trainLocation.0) + "," +  String(describing: trainLocation.1)
        
        networkModel.loadFromNetwork(location: locationCoordinates, term: "food", finished: {[weak self](dictionary, error) in
            print("In return from ajaxRequest: \(Thread.current)")
            
            guard let restaurantResultArray = dictionary?["businesses"] as? [ [String: AnyObject] ] else {
                print("data format error: \(dictionary?.description ?? "[Missing dictionary]")")
                return
            }
            
            OperationQueue.main.addOperation {
                print("Passing restaurant results to main operation queue: \(Thread.current)")
                
                self?.restaurantsFromNetwork.removeAll()
  
                restaurantResultArray.forEach { (restaurant) in
                    
                    guard let url : String = restaurant["image_url"] as? String else{
                        preconditionFailure("Name not found in JSON")
                    }
                    
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
                    
                    guard let location : NSDictionary = restaurant["location"] as? NSDictionary else{
                        preconditionFailure("latitude not found in JSON")
                    }
                    
                    guard let addressArr : NSArray = location["display_address"] as? NSArray else{
                        preconditionFailure("display_address not found in JSON")
                    }
                    
                    let addressFirstComponent = addressArr.count > 0 ? String(describing: addressArr[0] as? String ?? "" ) : ""
                    let addressSecondComponent = addressArr.count > 1 ? String(describing: addressArr[1] as? String ?? "" ) : ""
                    
                    let completeAddress = addressFirstComponent + addressSecondComponent
                    
                    let restaurant = Restaurant(_url: url, _trainStop : trainStop, _restaurantName: name, _restaurantId: id, _latitude: lat, _longitude: long, _givenRating: Int(rating), _displayAddress :  completeAddress)
                    
                    if(self?.restaurantsSaved.filter({$0.restaurantId == restaurant.restaurantId}).count ?? 0 > 0)
                    {
                        restaurant.isFavorite = true
                    }

                    if(restaurant.distanceFromTrainStop <= 2){ // Loading only those data that are less than 2 miles. Idea is to see restaurants in walking distance
                        
                        print("Adding restaurant \(restaurant.restaurantName)")
                        self?.restaurantsFromNetwork.append(restaurant)
                    }
                }
                
                 print("Before Caching layer")
                 self?.searchedRestaurants[trainStop.stopName] = self?.restaurantsFromNetwork
                print("Caching layer")
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantLoadedFromNetwork), object: self))
            }
            
        } )
        
        print("Number of Records now in restaurant Array is \(restaurantsFromNetwork.count)")
    }
}
extension RestaurantModel{
    
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
    
    func addRestaurantToFavorite(restaurantOpt: Restaurant?) throws{
      
        guard let restaurant =  restaurantOpt else{
            throw RestaurantError.invalidRestaurant()
        }
        
        restaurant.isFavorite = true
        restaurantsSaved.append(restaurant)
        
        let nsNotification = NSNotification(name: NSNotification.Name(rawValue: Messages.RestaurantReadyToBeSaved), object: nil)
        NotificationCenter.default.post(name: nsNotification.name, object: nil, userInfo:[Consts.KEY0: restaurant])
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.FavoriteListChanged), object: self))
    }
   
    func restoreRestaurantsFromFavorite(restaurants : [Restaurant]){
        restaurantsSaved = restaurants
    }
    
    func editRestaurantInFavorite(restaurant: Restaurant) throws{
        
        guard restaurantsSaved.contains(restaurant) else{
            throw RestaurantError.notAbleToEdit(name: restaurant.restaurantName)
        }
        let nsNotification = NSNotification(name: NSNotification.Name(rawValue: Messages.RestaurantReadyToBeSaved), object: nil)
        NotificationCenter.default.post(name: nsNotification.name, object: nil, userInfo:[Consts.KEY0: restaurant])

        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.FavoriteListChanged), object: self))
   }
    
    func deleteRestaurantFromFavorite(restaurant: Restaurant) throws{
        
        if(restaurantsSaved.contains{$0.restaurantId == restaurant.restaurantId}){
            restaurant.isFavorite = false
            restaurantsSaved = restaurantsSaved.filter({($0.restaurantId != restaurant.restaurantId)})
        }
        else{
            throw RestaurantError.notAbleToDelete(name: restaurant.restaurantName)
        }
        
        let nsNotification = NSNotification(name: NSNotification.Name(rawValue: Messages.RestaurantDeleted), object: nil)
        NotificationCenter.default.post(name: nsNotification.name, object: nil, userInfo:[Consts.KEY0: restaurant])
   
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.FavoriteListChanged), object: self))
    }
}

extension RestaurantModel{
    func generateEmptyRestaurant() throws-> Restaurant{
        let trainStop = try TrainStop(_stopName: "", _latitude: 0.0, _longitude: 0.0)
        let restaurant = Restaurant(_url: "", _trainStop: trainStop, _restaurantName: "", _restaurantId: "", _latitude: 0.0, _longitude: 0.0, _givenRating: 0, _displayAddress: "")
       
        return restaurant
    }
}

class Restaurant:  NSObject, NSCoding{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(restaurantId, forKey: "restaurantId")
        aCoder.encode(restaurantName, forKey: "restaurantName")
        aCoder.encode(givenRating, forKey: "givenRating")
        aCoder.encode(myRating, forKey: "myRating")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(comments, forKey: "displayedAddress")
        aCoder.encode(distanceFromStopDesc, forKey: "distanceFromStopDesc")
        aCoder.encode(dateVisited, forKey : "dateVisited")
        aCoder.encode(isFavorite, forKey : "isFavorite")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard
            let restId = aDecoder.decodeObject(forKey: "restaurantId") as? String,
            let restName = aDecoder.decodeObject(forKey: "restaurantName") as? String,
            let restComment = aDecoder.decodeObject(forKey:"comments") as? String,
            let restAddress = aDecoder.decodeObject(forKey:"displayedAddress") as? String,
            let restDistanceDesc = aDecoder.decodeObject(forKey:"distanceFromStopDesc") as? String,
            let restDate = aDecoder.decodeObject(forKey:"dateVisited") as? Date else {
                return nil
        }
        
        restaurantId = restId
        restaurantName = restName
        givenRating = aDecoder.decodeInteger(forKey: "givenRating")
        myRating = aDecoder.decodeInteger(forKey: "myRating")
        comments = restComment
        displayedAddress = restAddress
        dateVisited = restDate
        isFavorite = aDecoder.decodeBool(forKey: "isFavorite")
        distanceFromStopDesc = restDistanceDesc
        super.init()
    }
    
    var trainStop : TrainStop?
    var restaurantName : String = ""{
        didSet{
            if(restaurantId.isEmpty){
                restaurantId = String(describing: RestaurantModel.getTotalFavoriteCount())
            }
        }
    }
    var imageURL: String = ""
    var restaurantId : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var distanceFromStopDesc : String = ""
    var distanceFromTrainStop : Double{
        
        let distance = self.distanceBetweenTwoCoordinates(lat1: latitude, lon1: longitude, latOpt: trainStop?.latitude, lonOpt: trainStop?.longitude).rounded(toPlaces: 1)
        
        if let stop = self.trainStop{
            distanceFromStopDesc = String(describing:distance) + " mi from " + String(describing: stop.stopName)
        }
        return distance
    }
    
    var givenRating : Int = 0{
        didSet{
            myRating = givenRating
        }
    }
    var myRating : Int = 0
    var isSelected : Bool = false
    var comments : String = ""
    var dateVisited : Date = Date()
    var favoriteImageName : String = "heart"
   // var restaurantImage
    var isFavorite : Bool = false{
        didSet{
            if(isFavorite){
                favoriteImageName = "savedHeart"
            }else{
                favoriteImageName = "heart"
            }
        }
    }
    var displayedAddress: String = ""
   
    init(_url: String, _trainStop : TrainStop, _restaurantName : String, _restaurantId : String, _latitude : Double, _longitude : Double, _givenRating : Int, _displayAddress : String)
    {
        imageURL = _url
        trainStop = _trainStop
        restaurantName = _restaurantName
        restaurantId = _restaurantId
        latitude = _latitude
        longitude = _longitude
        givenRating = _givenRating
        myRating = _givenRating
        displayedAddress = _displayAddress
    }
}

//Distance between 2 points - Code snippet from https://www.geodatasource.com/developers/swift
extension Restaurant{
    
    func distanceBetweenTwoCoordinates(lat1:Double, lon1:Double, latOpt:Double?, lonOpt:Double?) -> Double {
        
        guard let lat2 = latOpt, let lon2 = lonOpt else{
            preconditionFailure("Could not calculate distance")
        }
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        return dist
    }
    
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }
    
    func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }
}
//Code snippet from StackOverflow
extension Double {
func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
