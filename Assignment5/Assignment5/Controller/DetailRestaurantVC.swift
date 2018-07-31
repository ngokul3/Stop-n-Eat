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
    @IBOutlet weak var txtRestaurantName: UITextField!
    @IBOutlet weak var lblDistance: UILabel!
    
    private static var modelObserver: NSObjectProtocol?
    private lazy var btnRatings : [UIButton] = [btnRating1, btnRating2, btnRating3, btnRating4, btnRating5]
    
    var restaurant : Restaurant?
    var goBackAction : ((UIAlertAction) -> Void)?
    var restaurantDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?
    
    lazy var viewState = RatingViewState(myRatingOpt: self.restaurant?.myRating, MaxRating: 5)

    lazy var ratingImageClosure :(Restaurant,Int)->RatingViewState.RatingType = {[weak self](restaurant: Restaurant, rating: Int)->RatingViewState.RatingType in
        if(restaurant.givenRating >= rating){
            return.full
        }else{
            return .empty
        }
    }
    
    lazy var updateRating:(UIButton)->Void = {[weak self] (button: UIButton) in
        var imageNameOpt : String?
        let btnIndexOpt = self?.btnRatings.index(of: button)
        
        guard let btnIndex = btnIndexOpt else{
            return
        }
        
        let ratingTypeOpt = self?.viewState.getRatingType(ratingButtonIndex: btnIndex)
        
        guard var ratingType = ratingTypeOpt else{
            return
        }
        
        self?.viewState.changeRatingType(ratingButtonIndex: btnIndex, returnRatingImageName: {(imageName) in
            button.setBackgroundImage(UIImage(named: imageName), for: .normal)
        })
    }
    
    lazy var setUpButtonImages:(Int)->Void = {[weak self](rating: Int) in
        self?.btnRatings.forEach{(btn) in
            let btnIndex = self?.btnRatings.index(of: btn)
           
            guard let index = btnIndex,
                  let fullImageName = self?.viewState.fullRatingImageName,
                  let emptyImageName = self?.viewState.emptyRatingImageName else{
                return
            }
            guard let imageName = self?.viewState.fullRatingImageName else{
                return
            }
            if(rating > index){
                
                btn.setBackgroundImage(UIImage(named: fullImageName), for: .normal)
            }
            else{
                btn.setBackgroundImage(UIImage(named: emptyImageName), for: .normal)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        
//        btnRatings.forEach{(btn) in
//            let btnIndex = btnRatings.index(of: btn)
//            guard let index = btnIndex else{
//                return
//            }
//            if(rating > index){
//                btn.setBackgroundImage(UIImage(named: viewState.fullRatingImageName), for: .normal)
//            }
//            else{
//                btn.setBackgroundImage(UIImage(named: viewState.emptyRatingImageName), for: .normal)
//            }
//        }
        switch detailType {
        
        case .Add : setUpButtonImages(0)
            
        case .Edit, .Preload :
            
            guard let restaurantInContext = restaurant else
            {
                preconditionFailure("Parent VC did not initialize MenuItem")
            }
            
            txtRestaurantName.text = restaurantInContext.restaurantName
            dateVisited.date = restaurantInContext.dateVisited
            lblDistance.text = restaurantInContext.distanceFromStopDesc
            let rating = restaurantInContext.myRating
            setUpButtonImages(rating)
       
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
        let fullStarCount = viewState.ratingButtonArr.filter{$0.rawValue == RatingViewState.RatingType.full.rawValue}.count
        restaurant?.myRating = fullStarCount
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
    @IBAction func btnRating1Click(_ sender: UIButton) {
        self.updateRating(sender)
    }
    
    @IBAction func btnRating2Click(_ sender: UIButton) {
        self.updateRating(sender)
    }
 
    @IBAction func btnRating3Click(_ sender: UIButton) {
        self.updateRating(sender)
    }
    @IBAction func btnRating4Click(_ sender: UIButton) {
        self.updateRating(sender)
    }
    @IBAction func btnRating5Click(_ sender: UIButton) {
        self.updateRating(sender)
    }
    
}



