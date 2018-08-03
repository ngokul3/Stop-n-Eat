//
//  Types.swift
//  TransitBreak
//
//  Created by Gokula K Narasimhan on 7/27/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

protocol TrainStopProtocol {
    static func getInstance() -> TrainStopProtocol
     func getTrainStop(fromFilteredArray stopIndex : Int) throws ->TrainStop
    func getAllTrains()->[TrainStop] //Todo reiew these get func. YOu dont need this
    var filteredStops : StopArray {get set}
    var currentFilter : String {get set}
    func loadTransitData(completed : @escaping (String?)->Void) throws
    
 }

protocol RestaurantProtocol{
    static func getInstance()->RestaurantProtocol
    func loadRestaurantFromNetwork(trainStop : TrainStop) throws
    var restaurantsFromNetwork: RestaurantArray {get set}
    var restaurantsSaved: RestaurantArray {get set}
    func getRestaurantFromNetwork(fromRestaurantArray stopIndex : Int) throws ->Restaurant
    func getAllRestaurantsFromNetwork() throws ->RestaurantArray
    func addRestaurantToFavorite(restaurantOpt: Restaurant?) throws
    func editRestaurantInFavorite(restaurant: Restaurant) throws
    func deleteRestaurantFromFavorite(restaurant: Restaurant) throws
    func restoreRestaurantsFromFavorite(restaurants : [Restaurant])
    func generateEmptyRestaurant() throws-> Restaurant
}


enum TrainStopError: Error{
    case invalidRowSelection()
    case invalidStopName()
    case invalidLocation()
    case notAbleToPrepopulate()
    case invalidJSONFile()
}

enum RestaurantError: Error{
    case invalidRestaurant()
    case invalidRowSelection()
    case zeroCount()
    case notAbleToPopulateRestaurants()
    case notAbleToAdd(name : String)
    case notAbleToEdit(name: String)
    case notAbleToDelete(name: String)
    case notAbleToSave(name: String)
    case notAbleToRestore()
    case notAbleToCreateEmptyRestaurant()
}
struct Messages {
    static let StopListFiltered = "Train Stops Filtered"
    static let RestaurantLoadedFromNetwork = "Restaurants From Network Loaded"
    static let RestaurantReadyToBeSaved = "Restaurant refreshed to Favorite"
    static let FavoriteListChanged = "Add, Delete or Edit on the Restaurant Model"
    static let RestaurantDeleted = "Restaurant Deleted from Saved list"
    static let RestaurantCanBeRemovedFromFavorite = "Restaurant cane be Deleted from Saved list"
    static let ImageArrived = "Image arrived"
}

enum DetailVCType : String
{
    case Add
    case Edit
    case Preload
}

struct Consts{
    static let KEY0 = "Key0"
}

extension Collection{
    subscript(index: Int) -> Bool{
        guard   index >= 0
            ,self.count > index else{
                return false
        }
        return true
    }
}

extension String{
    
    func getTruncatedAddress(firstAddress : String, seperator : String) -> String
    {
        var shortAddress = firstAddress
        let addressLine = self.components(separatedBy: ",")
        if(addressLine.count > 0){
            shortAddress =  shortAddress + seperator + addressLine[0]
        }
        
        return shortAddress
    }
    
}
