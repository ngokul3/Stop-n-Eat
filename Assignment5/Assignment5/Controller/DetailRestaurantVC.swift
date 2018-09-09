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
    private var notifyModel = AppDel.notifyModel
    private var emptyRatingImageName: String = "plainStar" // This image name is not  model specific. So, not having it in Model
    private var fullRatingImageName: String = "rating"

    var restaurant : Restaurant?
    var restaurantDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?
    var scrollView: UIScrollView!
    
    lazy var isRestaurantSetToNotify : (Restaurant, Restaurant)->Bool = {(restaurantInNotify, restaurantSaved) in
        
        if (restaurantInNotify.restaurantId == restaurantSaved.restaurantId) {
            return true
        }
        else{
            return false
        }
    }
    
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
        self.btnRatings.forEach{ (btn) in
            
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
                    }
                    else{
                        print("Image data not available")
                    }
                }
                else{
                    print("HTTP Error \(httpResponse.statusCode)")
                }
            }
            else{
                print("Can't parse imageresponse")
            }
        }
    }
    
     override func viewDidLoad() {
        super.viewDidLoad()
       
        scrollView = UIScrollView(frame: view.bounds)
         scrollView.contentSize = view.bounds.size
        scrollView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        
         scrollView.addSubview(view)
        
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
            }
            else{
                setUpButtonImages(0)
            }
            
        case .Edit, .Preload :
            
            guard let restaurantInContext = restaurant else{
                preconditionFailure("Restaurant is nil")
            }
            
            txtRestaurantName.text = restaurantInContext.restaurantName
            dateVisited.date = restaurantInContext.dateVisited
            lblDistance.text = restaurantInContext.distanceFromStopDesc
            txtNotes.text = restaurantInContext.comments
            let rating = restaurantInContext.myRating
            setUpButtonImages(rating)
        }
        
        /*Add does not only mean "+" from SavedRestVC. Add can also be done from RestaurantVC and on click of heart image.
         So, below guard needs to be done again.
         I would like to display state of Notify switch for Add from RestaurantVC. If it notify is turned on in RestaurantVC, the state
         would be preserved here.
         But if Add comes from SavedRestVC on click of "+", guard will just return. The default of notify will be false anyway
         */
        
        guard let restaurantAddOrEdit = restaurant else{
            return
        }
        
        if(notifyModel.getRestaurantsToNotify().contains{isRestaurantSetToNotify($0, restaurantAddOrEdit)}){
            restaurantAddOrEdit.isSelected = true
            swtNotify.isOn = true
        }
        else{
            restaurantAddOrEdit.isSelected = false
            swtNotify.isOn = false
        }
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
        
        guard let name = txtRestaurantName.text,
              !name.isEmpty else{
            alertUser = "Restaurant Name cannot be empty"
            return
        }
        
        restaurant?.restaurantName = name
        restaurant?.dateVisited = dateVisited.date
        restaurant?.comments = txtNotes.text
        restaurant?.myRating = self.myRating
        
        switch swtNotify.isOn {
        
        case true:
            restaurant?.isSelected = true
            
            if let restaurantToNotify = restaurant{
                notifyModel.addRestaurantToNotify(restaurantToNotify: restaurantToNotify)
            }
            
        case false:
            restaurant?.isSelected = false
            
            if let restaurantToNotify = restaurant{
            
                if(notifyModel.getRestaurantsToNotify().contains{isRestaurantSetToNotify($0, restaurantToNotify)}){
                    do{
                        try notifyModel.removeRestauarntFromNotification(restaurant: restaurantToNotify)
                    }
                    catch{
                        alertUser = "Restaurant could not be removed from notify list"
                        return
                    }
                }
            }
        }
       
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





