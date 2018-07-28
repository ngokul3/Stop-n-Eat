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
    var filteredStops : StopArray
    var currentFilter : String = ""{
        didSet{
            
            if(!currentFilter.isEmpty){
                filterTrainStops(stopName: currentFilter)
                
            }
            else{
                filteredStops = StopArray()
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
    //Todo should be async call
    
    func filterTrainStops(stopName: String) {
        
        guard trainStops.count > 0 else
        {
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
    
    func loadTransitData(JSONFileFromAssetFolder fileName: String, completed : ([TrainStop])->Void) throws {
    //Todo
//        DispatchQueue.global(qos: .background).async {
//            //background code
//            DispatchQueue.main.async {
//                //your main thread
//            }
//        }
        
        
        let jsonResult: Any?
        if let path = Bundle.main.path(forResource: "RailStop", ofType: "json")
        {
            do{
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                }
            catch{
                throw TrainStopError.invalidJSONFile()
            }
            
            guard let stopArray = jsonResult as? NSArray else {
                return
            }
            
            do{
                try stopArray.forEach({(arg) in
                
                    guard let stopDict = arg as? NSDictionary else{
                        return
                    }
                    
                    let stopName = stopDict["stop_name"] as? String
                    let latitude = stopDict["stop_lat"] as? Double
                    let longitude = stopDict["stop_lon"] as? Double
                    
                    try self.trainStops.append(TrainStop(_stopName: stopName, _latitude: latitude, _longitude: longitude) )
                })
            }
            catch{
                throw TrainStopError.notAbleToPrepopulate()
            }
            
            print(type(of: stopArray[0]))
        }
    }
    
    
}
extension TrainStopModel{
    
    func addTrainStop(stop: TrainStop) throws {
     
        trainStops.append(stop)
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.StopListChanged), object: self))
    }
    
    func getTrainStop(stopNo: Int) throws -> TrainStop? {
        
        guard trainStops.count >= stopNo else //check for array bounds
        {
            preconditionFailure("Not able to fetch the requested Train Stop")
        }
        
       
        return trainStops.filter{$0.stopNo == stopNo}.first
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
