//
//  SavedRestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/26/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class SavedRestaurantVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var restModel = AppDel.restModel
    private var notifyModel = AppDel.notifyModel
    private static var modelObserver: NSObjectProtocol?
    
    lazy var isRestaurantSetToNotify : (Restaurant, Restaurant)->Bool = {(restaurantInNotify, restaurantSaved) in
        
        if (restaurantInNotify.restaurantId == restaurantSaved.restaurantId) {
            return true
        }
        else{
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension

        SavedRestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantDeleted), object: nil, queue: OperationQueue.main) {
           
            [weak self] (notification: Notification) in
            if let s = self {
                let info0 = notification.userInfo?[Consts.KEY0]
                let restaurantOpt = info0 as? Restaurant
                guard let restaurant = restaurantOpt else{
                    preconditionFailure("Could not save this favorite restaurant")
                }
                s.deleteRestaurant(restaurant: restaurant)
            }
        }
        
        SavedRestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantListChanged), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
    }
}

extension SavedRestaurantVC : UITableViewDataSource{

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedRestaurantCell", for: indexPath) as? SavedRestaurantCell else{
            preconditionFailure("Incorrect Cell provided")
        }
        
        var restaurantSaved: Restaurant?
        do{
            restaurantSaved = try restModel.getRestaurantSaved(fromSavedRestaurantArray: indexPath.row)
        }
        catch{
            print("Unexpected Error while framing cell")
        }
        
        guard let restaurant = restaurantSaved  else{
            preconditionFailure("Restaurant list did not get loaded")
        }

        print("Returned name is \(restaurant.restaurantName)")
        cell.lblRestaurantName.text = restaurant.restaurantName
        cell.txtNotesRestaurant.text = restaurant.comments
        cell.txtDateSaved.text = restaurant.dateVisited.returnFormattedDate()
        let rating = restaurant.myRating
        let imgStarArr = [cell.imgStar1, cell.imgStar2, cell.imgStar3, cell.imgStar4, cell.imgStar5]
        
        imgStarArr.forEach({(img) in
            
            guard let imgIndex = imgStarArr.index(of: img) else{
                preconditionFailure("Can't load images")
            }
            
            if (rating > imgIndex){
                img?.image = UIImage(named: "rating")
            }
            else{
                img?.image = UIImage(named: "plainStar")
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restModel.getAllRestaurantsPersisted().count
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            do{
                let restaurantInContext = try restModel.getRestaurantSaved(fromSavedRestaurantArray: indexPath.row)
                
                try restModel.deleteRestaurantFromFavorite(restaurant: restaurantInContext)
                
                if(self.notifyModel.getRestaurantsToNotify().contains{isRestaurantSetToNotify($0, restaurantInContext)}){
                    alertUser = "Please note that \(restaurantInContext.restaurantName) is in the Notify List. Please delete from Notify tab if you don't want to Notify."
                }
            }
            catch RestaurantError.notAbleToDelete(let name){
                alertUser = "\(name) cannot be deleted"
            }
            catch{
                alertUser = "Unexpected Error"
            }
        }
    }
}

extension SavedRestaurantVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
}

extension SavedRestaurantVC{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        guard let segueName = segue.identifier else{
            preconditionFailure("No segue identifier")
        }
        
        guard let detailVC = segue.destination as? DetailRestaurantVC else{
            preconditionFailure("Wrong destination type: \(segue.destination)")
        }
        
        switch String(describing: segueName){
            
        case "addSegue" :
            do{
                detailVC.restaurantDetailVCType = DetailVCType.Add
                detailVC.restaurant = try restModel.generateRestaurantPrototype()
                detailVC.saveDetailVC = {[weak self] (restaurant) in
                    do{
                        try self?.restModel.addRestaurantToFavorite(restaurantOpt: restaurant)
                    }
                    catch RestaurantError.invalidRestaurant(){
                        self?.alertUser = "Restaurant is nil"
                    }
                    catch{
                        self?.alertUser = "Unexpected error"
                    }
                }
            }
            catch RestaurantError.notAbleToCreateEmptyRestaurant(){
                self.alertUser = "Could not add restaurant"
            }
            catch{
                self.alertUser = "Unexpected error before launching favorite restaurant"
            }
            
        case "editSegue" :
           
            guard let cell = sender as? UITableViewCell,
                  let indexPath = self.tableView.indexPath(for: cell) else{
                    preconditionFailure("Segue from unexpected object: \(sender ?? "sender = nil")")
            }
            
            do{
                let restaurantInContext = try restModel.getRestaurantSaved(fromSavedRestaurantArray: indexPath.row)
                detailVC.restaurantDetailVCType = DetailVCType.Edit
                detailVC.restaurant = restaurantInContext
                detailVC.saveDetailVC = {[weak self] (restaurant) in
                    
                    do{
                        try self?.restModel.editRestaurantInFavorite(restaurant: restaurantInContext)
                    }
                    catch RestaurantError.notAbleToEdit(let name){
                        self?.alertUser = "Restaurant \(name) cannot be edited. May be it's not in Favorite list anymore."
                    }
                    catch{
                        self?.alertUser = "Unexpected error"
                    }
                }
            }
            catch{
                alertUser = "Unexpected error while selecting row for editing"
            }
            
        default : break
            
        }
    }
}

extension SavedRestaurantVC{
    
    func updateUI(){
        tableView.reloadData()
    }
    
    func deleteRestaurant(restaurant: Restaurant){
        do{
            if(restaurant.isFavorite){
                try Persistence.delete(restaurant)
            }
            else{
                print("Delete from database already complete")
            }
        }
        catch RestaurantError.notAbleToDelete(let name){
            alertUser = "Not able to delete \(name) from database"
        }
        catch {
            alertUser = "Unexpected Error"
        }
    }
    
    var alertUser :  String{
        get{
            preconditionFailure("You cannot read from this object")
        }
        set{
            let alert = UIAlertController(title: "Attention", message: newValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
}

//Code referred from http://ios-tutorial.com/working-dates-swift/
extension Date{
    
    func returnFormattedDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

