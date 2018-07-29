//
//  DetailRestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/29/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class DetailRestaurantVC: UIViewController {

    @IBOutlet weak var dateVisited : UIDatePicker!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var imgRating1: UIImageView!
    @IBOutlet weak var imgRating2: UIImageView!
    @IBOutlet weak var imgRating3: UIImageView!
    @IBOutlet weak var imgRating4: UIImageView!
    @IBOutlet weak var imgRating5: UIImageView!
    @IBOutlet weak var txtRestaurantName: UITextField!
    
    private static var modelObserver: NSObjectProtocol?
    var restaurant : Restaurant?
    var goBackAction : ((UIAlertAction) -> Void)?
    var restaurantDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        txtNotes.layer.borderColor = UIColor.gray.cgColor
        txtNotes.layer.borderWidth = 0.4
        txtNotes.layer.cornerRadius = 0.8
        
        DetailRestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantRefreshed), object: nil, queue: OperationQueue.main) {
            
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
        
        guard let detailType = restaurantDetailVCType else
        {
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
            txtNotes.text = "Prepopulate with distance from station" //todo
        default : break
        }
//        if(detailType == .Preload)
//        {
//            guard let restaurantInContext = restaurant else
//            {
//                preconditionFailure("Parent VC did not initialize MenuItem")
//            }
//
//            txtRestaurantName.text = restaurantInContext.restaurantName
//            dateVisited.date = restaurantInContext.dateVisited
//            txtNotes.text = "Prepopulate with distance from station" //todo
//        }
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

