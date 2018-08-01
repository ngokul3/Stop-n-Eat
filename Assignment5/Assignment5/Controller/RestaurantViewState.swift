////
////  RestaurantViewState.swift
////  Assignment5
////
////  Created by Gokula K Narasimhan on 7/30/18.
////  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
////
//
//import Foundation
//
////Todo - remove this file
//class RatingViewState{
//
//    enum RatingType : String{
//        case empty = "empty"
//        case full = "full"
//    }
//
//    var ratingButtonArr : [RatingType] = [RatingType]()
//    var emptyRatingImageName: String = "plainStar"
//    var fullRatingImageName: String = "rating"
//
//    init(myRatingOpt : Int?, MaxRating: Int){
//
//        guard let myRating = myRatingOpt else{
//            ratingButtonArr = Array(repeating: RatingType.empty, count: 5)
//            return
//        }
//
//        for index in 0...MaxRating-1{
//            if(index<myRating){
//                ratingButtonArr.append(.full)
//            }else{
//                ratingButtonArr.append(.empty)
//            }
//        }
//
//    }
//
//    func loadRatingType(ratingButtonIndex: Int, ratingType : RatingType){
//        guard ratingButtonArr[ratingButtonIndex] else{
//            preconditionFailure("View state does not contai this button index")
//        }
//       ratingButtonArr[ratingButtonIndex] = ratingType
//    }
//
//    func changeRatingType(ratingButtonIndex: Int,  returnRatingImageName: (String)->()){
//        guard ratingButtonArr[ratingButtonIndex] else{
//            preconditionFailure("View state does not contai this button index")
//        }
//
//        if ratingButtonArr[ratingButtonIndex].rawValue == "empty"{
//            ratingButtonArr[ratingButtonIndex] = .full
//            returnRatingImageName(self.fullRatingImageName)
//        }else{
//            ratingButtonArr[ratingButtonIndex] = .empty
//            returnRatingImageName(self.emptyRatingImageName)
//        }
//
//    }
//    func getRatingType(ratingButtonIndex: Int) -> RatingType?{
//        guard ratingButtonArr[ratingButtonIndex] else{
//            preconditionFailure("View state does not contain this button index")
//        }
//
//        return ratingButtonArr[ratingButtonIndex]
//    }
//
//    func changeRatingType_test(ratingButtonIndex: Int,  returnRatingImageName: (String)->()){
//        guard ratingButtonArr[ratingButtonIndex] else{
//            preconditionFailure("View state does not contai this button index")
//        }
//
//         ratingButtonArr.forEach({(arg) in
//            guard let index = ratingButtonArr.index(of: arg) else{
//                return
//            }
//            if(index < ratingButtonIndex){
//                ratingButtonArr[ratingButtonIndex] = .full
//
//            }else{
//                ratingButtonArr[ratingButtonIndex] = .empty
//            }
//
//        })
//
//    }
//}
