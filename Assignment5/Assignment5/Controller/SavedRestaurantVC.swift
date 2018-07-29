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
        
        do {
            let restoredObject = try Persistence.restore()
            model.restoreRestaurantsFromFavorite(restaurants: restoredObject)
        }
        catch RestaurantError.notAbleToRestore(){
            alertUser = "Not able to restore from the favorite list"
        }
        catch{
            alertUser = "Unknown Error"
        }
        SavedRestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantRefreshed), object: nil, queue: OperationQueue.main) {
            
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
        //cell.txtNotesRestaurant.text = restaurant.comments
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.restaurantsSaved.count
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
                        self?.alertUser = "Something went wrong while adding"
                    }
                }
            }
            
            catch RestaurantError.notAbleToCreateEmptyRestaurant(){
                self.alertUser = "Could not add restaurant"
            }
            catch{
                self.alertUser = "Something went wrong before launching detailed favorite restaurant"
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
//            detailVC.saveDetailVC = {[weak self] (restaurant) in
//                do{
//                    try self?.model.editRestaurantInFavorite(restaurant: restaurantInContext)
//                }
//                catch RestaurantError.notAbleToEdit(let name){
//                    self?.alertUser = "Restaurant \(name) cannot be edited"
//                }
//                catch{
//                    self?.alertUser = "Something went wrong while adding"
//                }
//            }
            
        default : break
        }
    }
}

extension SavedRestaurantVC{
    func updateUI()
    {
        tableView.reloadData()
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

