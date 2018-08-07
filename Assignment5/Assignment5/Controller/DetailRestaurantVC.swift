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
    @IBOutlet weak var imgRestaurantURL: UIImageView!
    private static var modelObserver: NSObjectProtocol?
    private lazy var btnRatings : [UIButton] = [btnRating1, btnRating2, btnRating3, btnRating4, btnRating5]
    private var myRating: Int = 0
    var restaurant : Restaurant?
    var restaurantDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?
    var emptyRatingImageName: String = "plainStar"
    var fullRatingImageName: String = "rating"

    lazy var updateRating = {(button: UIButton) in
        var imageNameOpt : String?
        let btnClickedIndexOpt = self.btnRatings.index(of: button)
        
        guard let btnClickedIndex = btnClickedIndexOpt else{
            return
        }
        self.myRating = 0
        self.btnRatings.forEach({(btn) in
            
            let btnIndexOpt = self.btnRatings.index(of: btn)
            guard let btnIndex = btnIndexOpt else{
                return
            }
            if(btnIndex <= btnClickedIndex){
                self.myRating += 1
                btn.setBackgroundImage(UIImage(named: self.fullRatingImageName), for: .normal)
                self.btnRating4.imageView?.contentMode = UIViewContentMode.scaleAspectFill
             }
            else{
                btn.setBackgroundImage(UIImage(named: self.emptyRatingImageName), for: .normal)
            }
        })
    }
    
    lazy var setUpButtonImages:(Int)->Void = {(rating: Int) in
        self.btnRatings.forEach{(btn) in
            
            let btnIndex = self.btnRatings.index(of: btn)
            guard let index = btnIndex else{
                return
            }
             if(rating > index){
                btn.setBackgroundImage(UIImage(named: self.fullRatingImageName), for: .normal)
            }
            else{
                btn.setBackgroundImage(UIImage(named: self.emptyRatingImageName), for: .normal)
            }
        }
    }
    
    lazy var setUpRestaurantImage: ((Data?, HTTPURLResponse?, Error?)-> Void) = {[weak self](data, response, error) in
        if let e = error {
            print("HTTP request failed: \(e.localizedDescription)")
        }
        else{
            if let httpResponse = response {
                print("http response code: \(httpResponse.statusCode)")
                
                let HTTP_OK = 200
                if(httpResponse.statusCode == HTTP_OK ){
                    
                    if let imageData = data{
                        OperationQueue.main.addOperation {
                            print("urlArrivedCallback operation: Now on thread: \(Thread.current)")
                            self?.imgRestaurantURL.image = UIImage(data: imageData)
                        }
                    }else{
                        print("Image data not available")
                    }
                    
                }else{
                    print("HTTP Error \(httpResponse.statusCode)")
                }
            }else{
                print("Can't parse imageresponse")
            }
        }
    }
    
     override func viewDidLoad() {
        super.viewDidLoad()
        txtNotes.layer.borderColor = UIColor.gray.cgColor
        txtNotes.layer.borderWidth = 0.4
        txtNotes.layer.cornerRadius = 0.8
        txtNotes.delegate = self
        txtRestaurantName.delegate = self
        myRating = restaurant?.myRating ?? 0
        AppDel.restModel.loadRestaurantImage(imageURLOpt: restaurant?.imageURL, imageLoaded: ({[weak self](data, response, error) in
           self?.setUpRestaurantImage(data, response, error)
        }))
        
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
            guard let restaurantInContext = restaurant else{
                preconditionFailure("Parent VC did not initialize MenuItem")
            }
            txtRestaurantName.text = restaurantInContext.restaurantName
            dateVisited.date = restaurantInContext.dateVisited
            lblDistance.text = restaurantInContext.distanceFromStopDesc
            txtNotes.text = restaurantInContext.comments
            let rating = restaurantInContext.myRating
            setUpButtonImages(rating)
        }
        swtNotify.isOn = restaurant?.isSelected ?? false
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
    
    @IBAction func btnBackClicked(_ sender: UIBarButtonItem) {
        if(restaurant?.restaurantName != txtRestaurantName.text){
            alertUser = "Restaurant Name was changed"
            return
        }
        if(restaurant?.comments != txtNotes.text){
            alertUser = "Notes about the restaurant was changed"
            return
        }
        if(restaurant?.dateVisited != dateVisited.date){
            alertUser = "Notes about the restaurant was changed"
            return
        }
        if(restaurant?.myRating != self.myRating){
            alertUser = "Restaurant rating was changed"
            return
        }
        if(restaurant?.isSelected != self.swtNotify.isOn){
            alertUser = "Restaurant Notify option was changed"
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSavedClicked(_ sender: UIBarButtonItem) {
        guard let name = txtRestaurantName.text
            , !name.isEmpty else{
            alertUser = "Restaurant Name cannot be empty"
            return
        }
        restaurant?.restaurantName = name
        restaurant?.dateVisited = dateVisited.date
        restaurant?.comments = txtNotes.text
        restaurant?.myRating = self.myRating
        restaurant?.isSelected = swtNotify.isOn
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
            alert.addAction(UIAlertAction(title: "Disregard", style: .default, handler: ({[weak self](arg) -> Void in
                self?.navigationController?.popViewController(animated: true)
            })))
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





