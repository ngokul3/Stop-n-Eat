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

class RatingViewState{
    typealias RatingNotifier = (RatingViewState.RatingType)->()
    
    enum RatingType{
        case empty
        case full
    }
    
    var ratingButtonDict = [Int : RatingType]()
    var ratingButtonNo: Int = 0
//    var notify = RatingNotifier.self
//
//    var ratingType : RatingType = .empty{
//        didSet{
//            guard oldValue != ratingType else{
//                return
//            }
//           notify(oldValue)
//        }
//    }
    
    init(){
        
    }
//    init(ratingButtonNo: Int, ratingType : RatingType, notify: @escaping RatingNotifier){
//        self.notify = notify
//        self.ratingType = ratingType
//        self.ratingButtonNo = ratingButtonNo
//    }
    
    func loadRatingType(ratingButtonNo: Int, ratingType : RatingType){
        ratingButtonDict[ratingButtonNo] = ratingType
    }
    
    func getRatingType(ratingButtonNo: Int) -> RatingType?{
        return ratingButtonDict[ratingButtonNo]
    }
}
