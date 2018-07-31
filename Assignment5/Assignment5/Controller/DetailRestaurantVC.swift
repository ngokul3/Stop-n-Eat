//
//  DetailRestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/29/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class DetailRestaurantVC: UIViewController {
  
    @IBOutlet weak var btnRating1: UIButton!
     @IBOutlet weak var btnRating2: UIButton!
     @IBOutlet weak var btnRating3: UIButton!
     @IBOutlet weak var btnRating4: UIButton!
     @IBOutlet weak var btnRating5: UIButton!
    @IBOutlet weak var dateVisited : UIDatePicker!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var imgRating1: UIImageView!
    @IBOutlet weak var imgRating2: UIImageView!
    @IBOutlet weak var imgRating3: UIImageView!
    @IBOutlet weak var imgRating4: UIImageView!
    @IBOutlet weak var imgRating5: UIImageView!
    @IBOutlet weak var txtRestaurantName: UITextField!
    @IBOutlet weak var lblDistance: UILabel!
    
    private static var modelObserver: NSObjectProtocol?
    var restaurant : Restaurant?
    var goBackAction : ((UIAlertAction) -> Void)?
    var restaurantDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?
    var viewState = RatingViewState()

    lazy var ratingImageClosure :(Restaurant,Int)->RatingViewState.RatingType = {[weak self](restaurant: Restaurant, rating: Int)->RatingViewState.RatingType in
        if(restaurant.givenRating >= rating){
            return.full
        }else{
            return .empty
        }
    }
    
    lazy var updateRating:(Int, (String)->())->Void = {[weak self] (buttonNo: Int, sendNewRatingImage : (String)->()) in
        
        let ratingTypeOpt = self?.viewState.getRatingType(ratingButtonNo: buttonNo)
        var imageNameOpt : String?
        guard var ratingType = ratingTypeOpt else{
            return
        }
        
        if ratingType == .empty{
            ratingType = .full
            imageNameOpt = self?.restaurant?.ratedImageName
        }else{
            ratingType = .empty
            imageNameOpt = self?.restaurant?.nonRatedImageName
        }
        
        self?.viewState.loadRatingType(ratingButtonNo: 1, ratingType: ratingType)
        
        guard let imageName = imageNameOpt else{
            return
        }
        sendNewRatingImage(imageName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        if(restaurantInContext.givenRating >= rating){
//            ratingState.ratingType = .full
//        }else{
//            ratingState.ratingType = .empty
//        }
//        imgRating1.isUserInteractionEnabled = true
//        imgRating1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DetailRestaurantVC.ratingClicked(_:no:) )))
        
        txtNotes.layer.borderColor = UIColor.gray.cgColor
        txtNotes.layer.borderWidth = 0.4
        txtNotes.layer.cornerRadius = 0.8
        
        DetailRestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantReadyToBeSaved), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                let info0 = notification.userInfo?[Consts.KEY0]
                
                let restaurantOpt = info0 as? Restaurant
                
                guard let restaurant = restaurantOpt else{
                    preconditionFailure("Could not save this favorite restaurant")
                }
                
                s.saveRestaurant(restaurant)
            }
        }
        
        guard let detailType = restaurantDetailVCType else{
            preconditionFailure("Parent VC did not initialize Detail VC Type")
        }
        
        switch detailType {
            
        case .Edit, .Preload :
            
            guard let restaurantInContext = restaurant else
            {
                preconditionFailure("Parent VC did not initialize MenuItem")
            }
            
            txtRestaurantName.text = restaurantInContext.restaurantName
            dateVisited.date = restaurantInContext.dateVisited
            lblDistance.text = restaurantInContext.distanceFromStopDesc
              let rating = restaurantInContext.givenRating
            
            switch rating{
            case 1 :
//                ratingState.ratingButtonNo = rating
//                ratingState.ratingType = ratingImageClosure(restaurantInContext, rating)
                viewState.loadRatingType(ratingButtonNo: rating, ratingType: ratingImageClosure(restaurantInContext, rating))
                btnRating1.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating2.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
                btnRating3.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
                btnRating4.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
                btnRating5.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
            case 2 :
                viewState.loadRatingType(ratingButtonNo: rating, ratingType: ratingImageClosure(restaurantInContext, rating))
                btnRating1.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating2.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating3.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
                btnRating4.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
                btnRating5.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
            case 3 :
                viewState.loadRatingType(ratingButtonNo: rating, ratingType: ratingImageClosure(restaurantInContext, rating))
                btnRating1.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating2.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating3.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating4.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
                btnRating5.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
            case 4 :
                viewState.loadRatingType(ratingButtonNo: rating, ratingType: ratingImageClosure(restaurantInContext, rating))
                btnRating1.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating2.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating3.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating4.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating5.setBackgroundImage(UIImage(named: "plainStar"), for: .normal)
            case 5 :
                viewState.loadRatingType(ratingButtonNo: rating, ratingType: ratingImageClosure(restaurantInContext, rating))
                btnRating1.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating2.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating3.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating4.setBackgroundImage(UIImage(named: "rating"), for: .normal)
                btnRating5.setBackgroundImage(UIImage(named: "rating"), for: .normal)
            default : break
            }
        default : break
        }
    }
}

extension DetailRestaurantVC{
    @IBAction func btnSavedClicked(_ sender: UIBarButtonItem) {
        
        guard let name = txtRestaurantName.text
            , !name.isEmpty else{
            alertUser = "Restaurant Name cannot be empty"
            return
        }
        
        restaurant?.restaurantName = name
        let returnType = viewState.ratingButtonDict.values
        
        //restaurant?.givenRatingrestaurant?.givenRating = viewState.ratingButtonDict.contains(where: { $0.value == Rating }))
        saveDetailVC?(restaurant)
        navigationController?.popViewController(animated: true)
    }
}

extension DetailRestaurantVC{
    func saveRestaurant(_ restaurant: Restaurant){
        do{
            
            try Persistence.save(restaurant)
        }
        catch RestaurantError.notAbleToSave(let name){
            alertUser = "Not able to save \(name) "
        }
        catch {
            alertUser = "Something went wrong while saving"
        }
    }
    
    var alertUser :  String{
        get{
            preconditionFailure("You cannot read from this object")
        }
        
        set{
            let alert = UIAlertController(title: "Changes not saved", message: newValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Stay", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Disregard", style: .default, handler: goBackAction))
            
            self.present(alert, animated: true)
        }
    }
}

extension DetailRestaurantVC{
    @IBAction func btnRating2Click(_ sender: UIButton) {
        self.updateRating(2, {(imageName) in
            btnRating2.setBackgroundImage(UIImage(named: imageName), for: .normal)
            }
        )
    }
    @IBAction func btnRating1Click(_ sender: UIButton) {
        self.updateRating(1, {(imageName) in
            btnRating1.setBackgroundImage(UIImage(named: imageName), for: .normal)
            }
        )
    }
    
    @IBAction func btnRating3Click(_ sender: UIButton) {
        self.updateRating(3, {(imageName) in
            btnRating3.setBackgroundImage(UIImage(named: imageName), for: .normal)
            }
        )
    }
    @IBAction func btnRating4Click(_ sender: UIButton) {
        self.updateRating(4, {(imageName) in
            btnRating4.setBackgroundImage(UIImage(named: imageName), for: .normal)
            }
        )
    }
    @IBAction func btnRating5Click(_ sender: UIButton) {
        self.updateRating(5, {(imageName) in
            btnRating5.setBackgroundImage(UIImage(named: imageName), for: .normal)
            }
        )
    }
}



