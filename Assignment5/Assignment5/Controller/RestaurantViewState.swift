//
//  RestaurantViewState.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/30/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation

class RatingViewState{
    
    enum RatingType : String{
        case empty = "empty"
        case full = "full"
    }
    
    var ratingButtonArr : [RatingType] = [RatingType]()
    var emptyRatingImageName: String = ""
    var fullRatingImageName: String = ""
    
    init(myRatingOpt : Int?, MaxRating: Int, emptyRatingImageName: String?, fullRatingImageName: String?){
        guard let myRating = myRatingOpt else{
            return
        }
        self.emptyRatingImageName = emptyRatingImageName ?? ""
        self.fullRatingImageName = fullRatingImageName ?? ""
        
        for index in 0...MaxRating-1{
            if(index<myRating){
                ratingButtonArr.append(.full)
            }else{
                ratingButtonArr.append(.empty)
            }
        }
        
    }
    
    func loadRatingType(ratingButtonIndex: Int, ratingType : RatingType){
        guard ratingButtonArr[ratingButtonIndex] else{
            preconditionFailure("View state does not contai this button index")
        }
        
        
       ratingButtonArr[ratingButtonIndex] = ratingType
        
        
    }
    
    func changeRatingType(ratingButtonIndex: Int,  returnRatingImageName: (String)->()){
        guard ratingButtonArr[ratingButtonIndex] else{
            preconditionFailure("View state does not contai this button index")
        }
        
        if ratingButtonArr[ratingButtonIndex].rawValue == "empty"{
            ratingButtonArr[ratingButtonIndex] = .full
            returnRatingImageName(self.fullRatingImageName)
        }else{
            ratingButtonArr[ratingButtonIndex] = .empty
            returnRatingImageName(self.emptyRatingImageName)
        }
        
    }
    func getRatingType(ratingButtonIndex: Int) -> RatingType?{
        guard ratingButtonArr[ratingButtonIndex] else{
            preconditionFailure("View state does not contain this button index")
        }
        
        return ratingButtonArr[ratingButtonIndex]
    }
}
