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
    func getAllTrains()->[TrainStop]
    func filterTrainStops(stopName : String)
    var currentFilter : String {get set}
    func loadTransitData (JSONFileFromAssetFolder fileName: String, completed : ([TrainStop])->Void) throws
}

enum TrainStopError: Error{
    case invalidStopName()
    case invalidLocation()
    case notAbleToPrepopulate()
    case invalidJSONFile()
}

struct Messages {
    static let StopListChanged = "Train Stop List changed"
    static let StopListFiltered = "Train Stops Filtered"
}

