//
//  Persistence.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/29/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

class Persistence {
    static let ModelFileName = "AppModel.serialized"
    static let FileMgr = FileManager.default
    
    static func getStorageURL() throws -> URL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if dirPaths.count == 0 {
            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "No paths found"])
        }
  
        let urlPath = URL(fileURLWithPath: dirPaths[0])
        if !FileMgr.fileExists(atPath: dirPaths[0]) {
            try mkdir(urlPath)
        }
        
        return urlPath.appendingPathComponent(ModelFileName)
    }
    
    static func mkdir(_ newDirURL: URL) throws {
        try FileManager.default.createDirectory(at: newDirURL, withIntermediateDirectories: false, attributes: nil)
    }
    
    static func delete(_ restaurant: Restaurant) throws{
        guard let alreadySavedData = UserDefaults.standard.data(forKey: "restaurants") else{
            return
        }
        
        if let alreadySavedRestaurants = NSKeyedUnarchiver.unarchiveObject(with: alreadySavedData) as? [Restaurant] {
            
            if(alreadySavedRestaurants.contains{$0.restaurantId == restaurant.restaurantId}){
                let restaurantsSaved = alreadySavedRestaurants.filter({($0.restaurantId != restaurant.restaurantId)})
                
                let savedData = NSKeyedArchiver.archivedData(withRootObject: restaurantsSaved)
                UserDefaults.standard.set(savedData, forKey: "restaurants")

            }
            else{
                throw RestaurantError.notAbleToDelete(name: restaurant.restaurantName)
            }
            
        }
    }
    
    static func save(_ restaurant: Restaurant) throws {
       
        var savedRestaurants = [Restaurant]()
        //savedRestaurants.append(restaurant)
        
        guard let alreadySavedData = UserDefaults.standard.data(forKey: "restaurants") else{
            return
        }
        
        if let alreadySavedRestaurants = NSKeyedUnarchiver.unarchiveObject(with: alreadySavedData) as? [Restaurant] {
            alreadySavedRestaurants.forEach {
                savedRestaurants.append($0)
            }
        }
        
        if(savedRestaurants.contains(restaurant)){
            savedRestaurants.forEach({(rest) in
                if(rest.restaurantId == restaurant.restaurantId){
                    rest.restaurantName = restaurant.restaurantName
                    rest.dateVisited = restaurant.dateVisited
                    rest.comments = restaurant.comments
                    rest.givenRating = restaurant.givenRating
                }
            })
        }
        else{
            savedRestaurants.append(restaurant)
        }
        
        let savedData = NSKeyedArchiver.archivedData(withRootObject: savedRestaurants)
        UserDefaults.standard.set(savedData, forKey: "restaurants")
        
        //Todo - remove below
        if let data = UserDefaults.standard.data(forKey: "restaurants"),
            let myRestList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Restaurant] {
            myRestList.forEach({print( $0.restaurantName)})
        } else {
            print("There is an issue")
        }
       
    }
    
    
    static func restore() throws -> [Restaurant] {
        var savedRestaurants = [Restaurant]()
     
        guard let alreadySavedData = UserDefaults.standard.data(forKey: "restaurants") else{
            return savedRestaurants
        }
        
        if let alreadySavedRestaurants = NSKeyedUnarchiver.unarchiveObject(with: alreadySavedData) as? [Restaurant] {
            savedRestaurants = alreadySavedRestaurants
        }
        
        return savedRestaurants
//        let saveURL = try Persistence.getStorageURL()
//        guard let rawData = try? Data(contentsOf: URL(fileURLWithPath: saveURL.path)) else {
//            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve unarchival data"])
//        }
//
//        let unarchiver = NSKeyedUnarchiver(forReadingWith: rawData)
//
//        guard let model = unarchiver.decodeObject(forKey: "root") as? NSObject else {
//            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to find root object"])
//        }
//        print("restored model successfully at \(Date()): \(type(of: model))")
//        return model
    }
}

