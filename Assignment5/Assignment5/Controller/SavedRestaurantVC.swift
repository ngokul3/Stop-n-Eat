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
    private var model = RestaurantModel.getInstance()
    private static var modelObserver: NSObjectProtocol?
    
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
        
        SavedRestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.FavoriteOrNotifyChanged), object: nil, queue: OperationQueue.main) {
            
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
        
        let restaurant = model.restaurantsSaved[indexPath.row]
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
            }else{
                img?.image = UIImage(named: "plainStar")
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.restaurantsSaved.count
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard  model.restaurantsSaved[indexPath.row] else{
                preconditionFailure("Error while getting value from the Menu Model")
            }
            
            let restaurantInContext = model.restaurantsSaved[indexPath.row]
            do{
                try model.deleteRestaurantFromFavorite(restaurant: restaurantInContext, completed: {[weak self](msgOpt) in
                    if let msg = msgOpt{
                        self?.alertUser = msg
                    }
                })
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
                detailVC.restaurant = try model.generateEmptyRestaurant()
                detailVC.saveDetailVC = {[weak self] (restaurant) in
                    do{
                        try self?.model.addRestaurantToFavorite(restaurantOpt: restaurant)
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
            guard let cell = sender as? UITableViewCell
                ,let indexPath = self.tableView.indexPath(for: cell) else{
                    preconditionFailure("Segue from unexpected object: \(sender ?? "sender = nil")")
            }
            
            guard  model.restaurantsSaved[indexPath.row] else{
                preconditionFailure("Error while getting value from the Menu Model")
            }
            
            let restaurantInContext = model.restaurantsSaved[indexPath.row]
            detailVC.restaurantDetailVCType = DetailVCType.Edit
            detailVC.restaurant = restaurantInContext
            detailVC.saveDetailVC = {[weak self] (restaurant) in
                do{
                    try self?.model.editRestaurantInFavorite(restaurant: restaurantInContext)
                }
                catch RestaurantError.notAbleToEdit(let name){
                    self?.alertUser = "Restaurant \(name) cannot be edited. May be it's not in Favorite list anymore."
                }
                catch{
                    self?.alertUser = "Unexpected error"
                }
            }
        default : break
        }
    }
}

extension SavedRestaurantVC{
    func updateUI()
    {
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

