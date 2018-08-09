//
//  NotifyModel.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 8/4/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

class NotifyModel: NotifyProtocol{
    
    private static var instance: NotifyProtocol?
    private var notifyRestaurants  = [Restaurant]()
    
    static func getInstance() -> NotifyProtocol {
        
        if let inst = NotifyModel.instance {
            return inst
        }
        
        let inst = NotifyModel()
        NotifyModel.instance = inst
        return inst
    }
    
    func getRestaurantsToNotify() -> [Restaurant] {
        return notifyRestaurants
    }
    
    lazy var isNotifiedRestaurantPresent : (Restaurant, Restaurant)->Bool = {(restaurantAleadyInNotify, restaurantToBeNotified) in
        
        if (restaurantAleadyInNotify.restaurantId == restaurantToBeNotified.restaurantId) {
            return true
        }
        else{
            return false
        }
    }
    
    func addRestaurantToNotify(restaurantToNotify: Restaurant) {
        
        if(!notifyRestaurants.contains{isNotifiedRestaurantPresent($0, restaurantToNotify)}){
            notifyRestaurants.append(restaurantToNotify)
        }
            
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantNotificationListChanged), object: self))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantListChanged), object: self))
    }
    
    func removeRestauarntFromNotification(restaurant: Restaurant) throws{
        
        if(notifyRestaurants.contains{$0.restaurantId == restaurant.restaurantId}){
             notifyRestaurants = notifyRestaurants.filter({($0.restaurantId != restaurant.restaurantId)})
             restaurant.isSelected = false
        }
        else{
            throw NotifyError.notAbleToRemoveRestaurant
        }
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantNotificationListChanged), object: self))
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.RestaurantListChanged), object: self))
    }
}
