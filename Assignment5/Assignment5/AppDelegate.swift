//
//  AppDelegate.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/24/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

var AppDel: AppDelegate {
    get {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    private var netModel = NetworkModel.getInstance()
    private var notModel = NotifyModel.getInstance()
    private var restaurantModel = RestaurantModel.getInstance()
    var window: UIWindow?

    var restModel: RestaurantProtocol {
        get {
            return restaurantModel
        }
    }
    
    var networkModel: NetworkProtocol {
        get {
            return netModel
        }
    }
    
    var notifyModel: NotifyProtocol {
        get {
            return notModel
        }
    }
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         return true
    }

}

