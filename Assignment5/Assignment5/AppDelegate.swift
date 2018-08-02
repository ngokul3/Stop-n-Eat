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
    private var restaurantModel = RestaurantModel.getInstance()
    private var netModel = NetworkModel.getInstance()
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}

