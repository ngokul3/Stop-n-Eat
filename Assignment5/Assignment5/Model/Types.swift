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
    func addTrainStop(stop: TrainStop) throws
    func getTrainStop(fromFilteredArray stopIndex : Int) throws ->TrainStop
    func getAllTrains()->[TrainStop] //Todo reiew these get func. YOu dont need this
    var filteredStops : StopArray {get set}
    var currentFilter : String {get set}
    func loadTransitData (JSONFileFromAssetFolder fileName: String, completed : ([TrainStop])->Void) throws
}

protocol RestaurantProtocol{
    static func getInstance()->RestaurantProtocol
    func addRestaurantFromNetwork(restaurantOpt : Restaurant?)
    func loadRestaurantFromNetwork(trainStop : TrainStop)
    var restaurantsFromNetwork : RestaurantArray {get set}
    func getRestaurantFromNetwork(fromRestaurantArray stopIndex : Int) throws ->Restaurant
    func getAllRestaurants() throws ->RestaurantArray
}


enum TrainStopError: Error{
    case invalidRowSelection()
    case invalidStopName()
    case invalidLocation()
    case notAbleToPrepopulate()
    case invalidJSONFile()
}

enum RestaurantError: Error{
    case invalidRowSelection()
    case zeroCount()
}
struct Messages {
    static let StopListChanged = "Train Stop List changed" //Todo this is not required
    static let StopListFiltered = "Train Stops Filtered"
    static let RestaurantLoadedFromNetwork = "Restaurants From Network Loaded"
}

