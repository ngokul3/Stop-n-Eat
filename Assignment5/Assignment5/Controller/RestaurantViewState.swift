//
//  RestaurantViewState.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/30/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation
//Todo - REmove this 
enum HeartType{
    case empty
    case full
}

class RestaurantViewState{
    private var handleChange: () -> Void
    var heartType : HeartType = .empty{
        didSet{
            handleChange()
        }
    }
    
    init(heartType : HeartType, handleChange: @escaping ()->Void){
        self.handleChange = handleChange
        self.heartType = heartType
    }
    
    
}
