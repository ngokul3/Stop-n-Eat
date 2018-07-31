//
//  RestaurantViewState.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/30/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

class RatingViewState{
    typealias RatingNotifier = (RatingViewState.RatingType)->()
    
    enum RatingType : String{
        case empty = "empty"
        case full = "full"
    }
    
    var ratingButtonArr : [RatingType] = [RatingType]()
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
    
    init(givenRatingOpt : Int?, MaxRating: Int){
        guard let givenRating = givenRatingOpt else{
            return
        }
        
        for index in 0...MaxRating{
            if(index<givenRating){
                ratingButtonArr.append(.full)
            }else{
                ratingButtonArr.append(.empty)
            }
        }
        
    }
    
    func loadRatingType(ratingButtonNo: Int, ratingType : RatingType){
        guard ratingButtonArr[ratingButtonNo] else{
            preconditionFailure("View state does not contai this button index")
        }
       ratingButtonArr[ratingButtonNo] = ratingType
    }
    
    func getRatingType(ratingButtonNo: Int) -> RatingType?{
        guard ratingButtonArr[ratingButtonNo] else{
            preconditionFailure("View state does not contain this button index")
        }
        
        return ratingButtonArr[ratingButtonNo]
    }
}
