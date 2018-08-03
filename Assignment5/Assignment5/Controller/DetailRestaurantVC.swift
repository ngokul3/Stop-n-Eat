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
    @IBOutlet weak var swtNotify: UISwitch!
   
    private static var modelObserver: NSObjectProtocol?
    private lazy var btnRatings : [UIButton] = [btnRating1, btnRating2, btnRating3, btnRating4, btnRating5]
    
    var restaurant : Restaurant?
    var goBackAction : ((UIAlertAction) -> Void)?
    var restaurantDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?
    var emptyRatingImageName: String = "plainStar"
    var fullRatingImageName: String = "rating"

    lazy var updateRating = {[weak self](button: UIButton) in
        var imageNameOpt : String?
        let btnClickedIndexOpt = self?.btnRatings.index(of: button)
        
        guard let btnClickedIndex = btnClickedIndexOpt else{
            return
        }
        
        self?.restaurant?.myRating = 0
        
        self?.btnRatings.forEach({(btn) in
            let btnIndexOpt = self?.btnRatings.index(of: btn)
            
            guard let btnIndex = btnIndexOpt,
                let fullImageName = self?.fullRatingImageName,
                let emptyImageName = self?.emptyRatingImageName else{
                return
            }
            
            if(btnIndex <= btnClickedIndex){
                self?.restaurant?.myRating += 1
                btn.setBackgroundImage(UIImage(named: fullImageName), for: .normal)
             }
            else{
                btn.setBackgroundImage(UIImage(named: emptyImageName), for: .normal)
            }
        })
    }
    
    lazy var setUpButtonImages:(Int)->Void = {[weak self](rating: Int) in
        self?.btnRatings.forEach{(btn) in
            let btnIndex = self?.btnRatings.index(of: btn)
           
            guard let index = btnIndex,
                  let fullImageName = self?.fullRatingImageName,
                  let emptyImageName = self?.emptyRatingImageName else{
                return
            }
            guard let imageName = self?.fullRatingImageName else{
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
    
    //Todo - bring in image next to info button
    override func viewDidLoad() {
        super.viewDidLoad()
    
        txtNotes.layer.borderColor = UIColor.gray.cgColor
        txtNotes.layer.borderWidth = 0.4
        txtNotes.layer.cornerRadius = 0.8
        txtNotes.delegate = self
        txtRestaurantName.delegate = self
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
        
        case .Add :
            
            if let restaurantInContext = restaurant {
                setUpButtonImages(restaurantInContext.myRating)
            }else{
                setUpButtonImages(0)
            }
            
        case .Edit, .Preload :
            
            guard let restaurantInContext = restaurant else
            {
                preconditionFailure("Parent VC did not initialize MenuItem")
            }
            
            txtRestaurantName.text = restaurantInContext.restaurantName
            dateVisited.date = restaurantInContext.dateVisited
            lblDistance.text = restaurantInContext.distanceFromStopDesc
            txtNotes.text = restaurantInContext.comments
            let rating = restaurantInContext.myRating
            setUpButtonImages(rating)
        }
        
        if(restaurant?.isSelected == true){
            swtNotify.isOn = true
        }else{
            swtNotify.isOn = false
        }
        //Todo - this has not been implemented yet.
        goBackAction  = ({[weak self](arg) -> Void in
            self?.navigationController?.popViewController(animated: true) // self is captured WEAK
        })
    }
}

extension DetailRestaurantVC: UITextViewDelegate, UITextFieldDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
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
        restaurant?.dateVisited = dateVisited.date
        restaurant?.comments = txtNotes.text
        saveDetailVC?(restaurant)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func swtNotify_Click(_ sender: UISwitch) {
        switch swtNotify.isOn{
        case true:
            restaurant?.isSelected = true
        case false:
            restaurant?.isSelected = false
        }
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



