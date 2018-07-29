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
    
    static func save(_ restaurants: [Restaurant]) throws {
       
        guard let alreadySavedData = UserDefaults.standard.data(forKey: "restaurants") else{
            return
        }
        
        guard var alreadySavedRestaurants = NSKeyedUnarchiver.unarchiveObject(with: alreadySavedData) as? [Restaurant] else{
            return
        }
        
        restaurants.forEach({
            print("Original count of restaurants in database is \(alreadySavedRestaurants.count)")
            print("This restaurant \($0.restaurantName) will be saved")
            alreadySavedRestaurants.append($0)
            print("Saved count of restaurants that will be saved is \(alreadySavedRestaurants.count)")
        })
        
        let savedData = NSKeyedArchiver.archivedData(withRootObject: alreadySavedRestaurants)
        UserDefaults.standard.set(savedData, forKey: "restaurants")
        
        if let data = UserDefaults.standard.data(forKey: "restaurants"),
            let myPeopleList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Restaurant] {
            myPeopleList.forEach({print( $0.restaurantName)})  
        } else {
            print("There is an issue")
        }
        
        
//        guard let restObject = defaults.object(forKey: "restaurants") as? Data else{
//             return
//        }
//        let restaurants = NSKeyedUnarchiver.unarchiveObject(with: restObject) as? [Restaurant]
//         print("success!: restaurant name :  \(restaurants?.first?.restaurantName)")
    }
    
    
    static func restore() throws -> NSObject {
        let saveURL = try Persistence.getStorageURL()
        guard let rawData = try? Data(contentsOf: URL(fileURLWithPath: saveURL.path)) else {
            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve unarchival data"])
        }
   
        let unarchiver = NSKeyedUnarchiver(forReadingWith: rawData)
        
        guard let model = unarchiver.decodeObject(forKey: "root") as? NSObject else {
            throw NSError(domain: "File I/O", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to find root object"])
        }
        print("restored model successfully at \(Date()): \(type(of: model))")
        return model
    }
}

