//
//  Persistence.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/29/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

class Persistence {

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
        
        //Printing saved data. Auditing purpose
        if let data = UserDefaults.standard.data(forKey: "restaurants"),
            let myRestList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Restaurant] {
            myRestList.forEach({print( "Saved Item - " + $0.restaurantName)})
        } else {
            print("There is an issue")
        }
    }
    
    static func save(_ restaurant: Restaurant) throws {
       
        var savedRestaurants = [Restaurant]()
        
        if let alreadySavedData = UserDefaults.standard.data(forKey: "restaurants") {
            if let alreadySavedRestaurants = NSKeyedUnarchiver.unarchiveObject(with: alreadySavedData) as? [Restaurant] {
                alreadySavedRestaurants.forEach {
                    savedRestaurants.append($0)
                }
            }
        }
        
        if(savedRestaurants.filter({$0.restaurantId == restaurant.restaurantId}).count != 0)
        {
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
        
        //Printing saved data. Auditing purpose
        if let data = UserDefaults.standard.data(forKey: "restaurants"),
            let myRestList = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Restaurant] {
            myRestList.forEach({print( "Saved Item - " + $0.restaurantName)})
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

    }
}

