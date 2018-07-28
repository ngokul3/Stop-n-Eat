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
    func getTrainStop(stopNo : Int) throws ->TrainStop?
    func getAllTrains()->[TrainStop] //Todo reiew these get func. YOu dont need this
    var filteredStops : StopArray {get set}
    var currentFilter : String {get set}
    func loadTransitData (JSONFileFromAssetFolder fileName: String, completed : ([TrainStop])->Void) throws
}

protocol RestaurantProtocol{
    static func getInstance()->RestaurantProtocol
    var networkDelegate : NetworkLayerListenerProtocol? {get set}
    func addRestaurantFromNetwork(restaurantOpt : Restaurant?)
   
}
enum TrainStopError: Error{
    case invalidStopName()
    case invalidLocation()
    case notAbleToPrepopulate()
    case invalidJSONFile()
}

enum RestaurantError: Error{
    
}
struct Messages {
    static let StopListChanged = "Train Stop List changed" //Todo this is not required
    static let StopListFiltered = "Train Stops Filtered"
    static let RestaurantLoadedFromNetwork = "Restaurants From Network Loaded"
}

