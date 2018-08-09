//
//  RestaurantModel.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/27/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//
typealias RestaurantArray = [Restaurant]
import Foundation

class RestaurantModel: RestaurantProtocol{
  
    private static var instance: RestaurantProtocol?
    private var searchedRestaurants = [String : RestaurantArray]()
    private var searchedRestaurantImage = [String : (Data,HTTPURLResponse)]()
    private var searchDistanceLimitOpt: Int?
    
   //May not be the best way to handle NetworkModel. Open for critics
    private lazy var networkModel = {
        return AppDel.networkModel
    }()
    
    private var restaurantsFromNetwork : RestaurantArray
    private var restaurantsSaved : RestaurantArray
    
    private init(){
        restaurantsFromNetwork = RestaurantArray()
        restaurantsSaved = RestaurantArray()
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictRootOpt = NSDictionary(contentsOfFile: path)
            
            guard let dict = dictRootOpt else{
                preconditionFailure("Yelp API is not available")
            }
            
            searchDistanceLimitOpt = dict["MilesAround"] as? Int
        }
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
        return getInstance().getAllRestaurantsPersisted().count
    }
}

extension RestaurantModel{
    
    func loadRestaurantImage(imageURLOpt: String?, imageLoaded: @escaping (Data?, HTTPURLResponse?, Error?)->Void){
        
        guard let imageURL = imageURLOpt else{
            print("Image URL was empty")
            return
        }
        
        if let (data, response) = searchedRestaurantImage[imageURL]{
            imageLoaded(data, response, nil)
        }
        else{
            networkModel.setRestaurantImage(forRestaurantImage: imageURL, imageLoaded: {[weak self](dataOpt, responseOpt, errorOpt) in
                
                guard let data = dataOpt,
                    let response = responseOpt else{
                        print("Image didn't load") // Not crashing the application just because the image was not available
                        return
                }
                
                self?.searchedRestaurantImage[imageURL] = (data, response)
                imageLoaded(data, response, errorOpt)
            })
        }
    }
}

extension RestaurantModel{
    
    func loadRestaurantFromNetwork(trainStop : TrainStop) throws{
        
        if let restaurantArray = searchedRestaurants[trainStop.stopName] {
            restaurantsFromNetwork = restaurantArray
            return
        }
        
        let trainLocation = (trainStop.latitude, trainStop.longitude)
    
        guard trainLocation.0 != 0.0,
              trainLocation.1 != 0.0 else{
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
                    var restaurantImageURL: String = ""
                    
                    if let imageURL = restaurant["image_url"] as? String{
                        restaurantImageURL = imageURL //Not guarding. Image URL isn't important
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
                    
                    var restaurantURL: String = ""
                    
                    if let restURL = restaurant["url"] as? String{
                        restaurantURL = restURL
                    }
                    
                    let addressFirstComponent = addressArr.count > 0 ? String(describing: addressArr[0] as? String ?? "" ) : ""
                    let addressSecondComponent = addressArr.count > 1 ? String(describing: addressArr[1] as? String ?? "" ) : ""
                    let completeAddress = addressFirstComponent + addressSecondComponent
                    
                    let restaurant = Restaurant(_url: restaurantURL, _imageUrl: restaurantImageURL, _trainStop : trainStop, _restaurantName: name, _restaurantId: id, _latitude: lat, _longitude: long, _givenRating: Int(rating), _displayAddress :  completeAddress)
                    
                    if let searchDistanceLimit = self?.searchDistanceLimitOpt{
                        if(restaurant.distanceFromTrainStop <= Double(searchDistanceLimit)){ // Loading only those data that are less than configured miles. Idea is to see restaurants in walking distance
                            
                            print("Adding restaurant \(restaurant.restaurantName)")
                            self?.restaurantsFromNetwork.append(restaurant)
                        }
                    }
                    
                    if let isRestaurantFavorite = (self?.getAllRestaurantsPersisted().contains{$0.restaurantId == restaurant.restaurantId ? true : false}){
                        
                        if(isRestaurantFavorite){
                            restaurant.isFavorite = true
                            restaurant.favoriteImageName = "favHeart"
                        }
                        else{
                            restaurant.isFavorite = false
                            restaurant.favoriteImageName = "emptyHeart"
                            
                        }
                    }
                }
                self?.searchedRestaurants[trainStop.stopName] = self?.restaurantsFromNetwork
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantListChanged), object: self))
            }
        } )
    }
}

extension RestaurantModel{
    
    func getRestaurantFromNetwork(fromRestaurantArray index : Int) throws ->Restaurant{
        
        guard let restaurantFromArray = restaurantsFromNetwork[safe: index]  else{
            throw RestaurantError.invalidRowSelection()
        }
        
        return restaurantFromArray
    }
    
    func getAllRestaurantsFromNetwork() ->RestaurantArray{
        return restaurantsFromNetwork
    }
    
    func getRestaurantSaved(fromSavedRestaurantArray index: Int) throws -> Restaurant{
        
        guard let restaurantSaved = restaurantsSaved[safe: index]  else{
            throw RestaurantError.invalidRowSelection()
        }
        
        return restaurantSaved
    }
    
    func getAllRestaurantsPersisted() -> RestaurantArray{
        return restaurantsSaved
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
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantListChanged), object: self))
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
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantListChanged), object: self))
   }
    
    func deleteRestaurantFromFavorite(restaurant: Restaurant) throws{
        
        if(restaurantsSaved.contains{$0.restaurantId == restaurant.restaurantId}){
            restaurantsSaved = restaurantsSaved.filter({($0.restaurantId != restaurant.restaurantId)})
            
            if let rest = restaurantsFromNetwork.filter({$0.restaurantId == restaurant.restaurantId}).first {
                rest.isFavorite = false
            }
        }
        else{
            throw RestaurantError.notAbleToDelete(name: restaurant.restaurantName)
        }
        
        let nsNotification1 = NSNotification(name: NSNotification.Name(rawValue: Messages.RestaurantCanBeRemovedFromFavorite), object: nil)
        let nsNotification2 = NSNotification(name: NSNotification.Name(rawValue: Messages.RestaurantDeleted), object: nil)
    
        NotificationCenter.default.post(name: nsNotification1.name, object: nil, userInfo:[Consts.KEY0: restaurant])
        NotificationCenter.default.post(name: nsNotification2.name, object: nil, userInfo:[Consts.KEY0: restaurant])
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantListChanged), object: self))
    }
}

extension RestaurantModel{
    
    func generateRestaurantPrototype() throws-> Restaurant{
        let trainStop = try TrainStop(_stopName: "", _latitude: 0.0, _longitude: 0.0)
        let restaurant = Restaurant(_url: "", _imageUrl: "", _trainStop: trainStop, _restaurantName: "", _restaurantId: "", _latitude: 0.0, _longitude: 0.0, _givenRating: 0, _displayAddress: "")
       
        return restaurant
    }
}

class Restaurant:  NSObject, NSCoding{
    
    init(_url: String, _imageUrl: String, _trainStop : TrainStop, _restaurantName : String, _restaurantId : String, _latitude : Double, _longitude : Double, _givenRating : Int, _displayAddress : String){
      
        restaurantURL = _url
        imageURL = _imageUrl
        trainStop = _trainStop
        restaurantName = _restaurantName
        restaurantId = _restaurantId
        latitude = _latitude
        longitude = _longitude
        givenRating = _givenRating
        myRating = _givenRating
        displayedAddress = _displayAddress
        
        if(_givenRating >= Consts.MinRatingToDisplayImage && _givenRating <= Consts.MaxRatingToDisplayImage){
            ratingImageName = "\(_givenRating)Stars"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        guard
            let restId = aDecoder.decodeObject(forKey: "restaurantId") as? String,
            let restName = aDecoder.decodeObject(forKey: "restaurantName") as? String,
            let restURL = aDecoder.decodeObject(forKey: "restaurantURL") as? String,
            let restImageURL = aDecoder.decodeObject(forKey: "imageURL") as? String,
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
        latitude = aDecoder.decodeDouble(forKey: "latitude")
        longitude = aDecoder.decodeDouble(forKey: "longitude")
        comments = restComment
        displayedAddress = restAddress
        dateVisited = restDate
        isFavorite = aDecoder.decodeBool(forKey: "isFavorite")
        distanceFromStopDesc = restDistanceDesc
        restaurantURL = restURL
        imageURL = restImageURL
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
    
    var restaurantURL: String
    var imageURL: String
    var restaurantId : String
    var latitude : Double
    var longitude : Double
    var distanceFromStopDesc : String = ""
    
    var distanceFromTrainStop : Double{
        let distance = self.distanceBetweenTwoCoordinates(lat1: latitude, lon1: longitude, latOpt: trainStop?.latitude, lonOpt: trainStop?.longitude).rounded(toPlaces: Consts.RoundDecimal)
        
        if let stop = self.trainStop{
            distanceFromStopDesc = String(describing:distance) + " mi from " + String(describing: stop.stopName)
        }
        
        return distance
    }
    
    var distanceShownWithImage : String{
        return String(describing: distanceFromTrainStop) + " mi"
    }
    
    var givenRating : Int = 0{
        didSet{
            myRating = givenRating
        }
    }
    
    var ratingImageName: String = ""
    var myRating : Int = 0
    var isSelected : Bool = false
    var comments : String = ""
    var dateVisited : Date = Date()
    var favoriteImageName : String = "emptyHeart"
    
    var isFavorite : Bool = false{
        didSet{
            if(isFavorite){
                favoriteImageName = "favHeart"
            }
            else{
                favoriteImageName = "emptyHeart"
            }
        }
    }
    
    var displayedAddress: String
   
    func encode(with aCoder: NSCoder) {
        aCoder.encode(restaurantId, forKey: "restaurantId")
        aCoder.encode(restaurantName, forKey: "restaurantName")
        aCoder.encode(restaurantURL, forKey: "restaurantURL")
        aCoder.encode(givenRating, forKey: "givenRating")
        aCoder.encode(myRating, forKey: "myRating")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(comments, forKey: "comments")
        aCoder.encode(displayedAddress, forKey: "displayedAddress")
        aCoder.encode(distanceFromStopDesc, forKey: "distanceFromStopDesc")
        aCoder.encode(dateVisited, forKey : "dateVisited")
        aCoder.encode(isFavorite, forKey : "isFavorite")
        aCoder.encode(imageURL, forKey: "imageURL")
    }
}

//Distance between 2 points - Code snippet from https://www.geodatasource.com/developers/swift
extension Restaurant{

    func distanceBetweenTwoCoordinates(lat1:Double, lon1:Double, latOpt:Double?, lonOpt:Double?) -> Double{
        
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
