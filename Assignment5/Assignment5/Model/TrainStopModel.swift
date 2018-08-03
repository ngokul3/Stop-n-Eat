//
//  TrainStopModel.swift
//  TransitBreak
//
//  Created by Gokula K Narasimhan on 7/27/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

typealias StopArray = [TrainStop]

class TrainStopModel {
   
    private static var instance: TrainStopProtocol?
    private var searchedStops = [String : StopArray]()
    private var trainStops : StopArray
    private lazy var networkModel = {
        return AppDel.networkModel
    }()
    var filteredStops : StopArray
    var currentFilter : String = ""{
        didSet{
            
            if(!currentFilter.isEmpty){
                filterTrainStops(stopName: currentFilter)
            }
            else{
                filteredStops = trainStops
            }
           
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.StopListFiltered), object: self))
        }
    }
    var storedStopFilter : StopArray?{
        return searchedStops[currentFilter]
    }
    
private init(){
        trainStops = StopArray()
        filteredStops = StopArray()
    }
}

extension TrainStopModel : TrainStopProtocol{
    
    static func getInstance() -> TrainStopProtocol {
        
        if let inst = TrainStopModel.instance {
            return inst
        }
        
        let inst = TrainStopModel()
        TrainStopModel.instance = inst
        return inst
    }
}
extension TrainStopModel{
    
    func filterTrainStops(stopName: String) {
        
        guard trainStops.count > 0 else {
            preconditionFailure("Not able to fetch Train Stops")
        }
        
        if let storedStops = storedStopFilter {
            filteredStops = storedStops
        }
        else{
            filteredStops =  trainStops.filter({(arg1) in
                return arg1.stopName.lowercased().contains(stopName.lowercased())
            })
            
            searchedStops[stopName] = filteredStops
        }
    }
    
    func loadTransitData(completed : @escaping (String?)->Void) throws{
        
        networkModel.loadTransitData(finished: ({[weak self] (jsonArray, error) in
            
            if let _ = error{
                completed("Json file is valid")
                return
            }
            
            guard let stopArray = jsonArray else {
                completed("Json file could not be parsed into Array")
                return
             }
            
            OperationQueue.main.addOperation {
                do{
                    try stopArray.forEach({(arg) in
                        
                        guard let stopDict = arg as? NSDictionary else{
                            preconditionFailure("Json file not valid")
                        }
                        
                        let stopName = stopDict["stop_name"] as? String
                        let latitude = stopDict["stop_lat"] as? Double
                        let longitude = stopDict["stop_lon"] as? Double
                        
                        try self?.trainStops.append(TrainStop(_stopName: stopName, _latitude: latitude, _longitude: longitude) )
                    })
                    self?.currentFilter = "" // For Model to post the event
                 }
                catch TrainStopError.notAbleToPrepopulate(){
                    completed("Json file could not be populated into the model")
                }
                catch{
                    completed("Unexpected Error while trying to populate from api call")
                }
            }
            
        }))
    }
 }

extension TrainStopModel{
    
    func getTrainStop(fromFilteredArray stopIndex : Int) throws ->TrainStop{

        guard filteredStops[stopIndex] else{
            throw TrainStopError.invalidRowSelection()
        }
        let stop = filteredStops[stopIndex]
        return stop
    }
    
    func getAllTrains() -> [TrainStop] {
         return trainStops
    }
}

class TrainStop{
    var stopNo  : Int = 0
    var stopName : String
    var latitude : Double
    var longitude : Double
    
    init(_stopName : String?, _latitude : Double?, _longitude : Double?) throws
    {
        guard let name = _stopName else{
            throw TrainStopError.invalidStopName()
        }
        
        guard let lat = _latitude,
              let long = _longitude else{
            throw TrainStopError.invalidLocation()
        }
        
        stopName = name
        latitude = lat
        longitude = long
    }
}



