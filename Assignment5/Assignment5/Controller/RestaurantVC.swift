//
//  RestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/25/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class RestaurantVC: UIViewController {
   
    @IBOutlet weak var btnFavoriteClick: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var trainStop : TrainStop?
    var cellArrray = [RestaurantCell]()
    private var restaurantModel = AppDel.restModel
    private static var modelObserver: NSObjectProtocol?
    var removeFavoriteNo : ((UIAlertAction, String)->Void)?
    var shouldRemoveFavorite : Bool?
    
    override func viewDidLoad() {
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        guard let stop = trainStop else{
            preconditionFailure("Could not find Stop")
        }
        do{
           try restaurantModel.loadRestaurantFromNetwork(trainStop: stop)
        }
        catch RestaurantError.notAbleToPopulateRestaurants(){
            alertUser = "Not able to populate restaurants at this time. Could be network related issue"
        }
        catch{
            alertUser = "Unexpected Error while populating Resaurants. Try again"
        }
   
        RestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantLoadedFromNetwork), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
        
        RestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.FavoriteListChanged), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
        
        RestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantCanBeRemovedFromFavorite), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                let info0 = notification.userInfo?[Consts.KEY0]
                
                let restaurantOpt = info0 as? Restaurant
                
                guard let restaurant = restaurantOpt else{
                    preconditionFailure("Could not save this favorite restaurant")
                }
                s.removeRestaurantFromFavoriteSavedList(restaurant: restaurant)
            }
        }
        
        super.viewDidLoad()
    }
}

extension RestaurantVC{
    @IBAction func btnSave(_ sender: Any) {
        var rowNo : Int?
        
        if let button = sender as? UIButton {
            rowNo = button.tag
        }
        
        guard let indexRow = rowNo else{
            preconditionFailure("Could not find corresponding row: \(sender )")
        }
        
        do{
            let _ = try restaurantModel.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
        }
        catch(RestaurantError.invalidRowSelection()){
            alertUser = "Restaurant selected could not be navigated to the map"
        }
        catch{
            alertUser = "Unexpected Error"
        }
    }
}

extension RestaurantVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantCell else{
            preconditionFailure("Incorrect Cell provided")
        }
        
        guard restaurantModel.restaurantsFromNetwork[indexPath.row] else{
            preconditionFailure("Restaurant list did not get loaded")
        }
    
        let restaurant = restaurantModel.restaurantsFromNetwork[indexPath.row]
        cell.lblRestaurantName.text = restaurant.restaurantName
        cell.lblMiles.text = String(describing: restaurant.distanceFromTrainStop) + " mi"
        cell.btnSingleMap.tag = indexPath.row
        let rating = restaurant.givenRating
        let imageName = "\(rating)Stars"
        cell.imgRatings.image = UIImage(named: imageName)

        cell.imgHeart.image = UIImage(named: restaurant.favoriteImageName)
        let heartTap : UITapGestureRecognizer?
        
        if(restaurant.isFavorite){
            heartTap = UITapGestureRecognizer(target: self, action: #selector(RestaurantVC.favoriteHeartTap(gesture: )))
        }else{
            heartTap = UITapGestureRecognizer(target: self, action: #selector(RestaurantVC.heartTap(gesture: )))
        }
        if let tap = heartTap{
            cell.imgHeart.addGestureRecognizer(tap)
            cell.imgHeart.isUserInteractionEnabled = true
            cell.imgHeart.tag = indexPath.row
        }
        
        restaurantModel.loadRestaurantImage(imageURL: restaurant.imageURL, imageLoaded: ({(data,response,error) in
                        cell.imageLoaderClosure(data, response, error)
                    })
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantModel.restaurantsFromNetwork.count
    }
 }

extension RestaurantVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark){
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            
            restaurantModel.restaurantsFromNetwork[indexPath.row].isSelected = false
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            restaurantModel.restaurantsFromNetwork[indexPath.row].isSelected = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark){
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            restaurantModel.restaurantsFromNetwork[indexPath.row].isSelected = false
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            restaurantModel.restaurantsFromNetwork[indexPath.row].isSelected = true
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
}

extension RestaurantVC{
    
    func removeFavorite(imageViewOpt: UIImageView?){
        
        guard let imageView = imageViewOpt else{
            alertUser = "Favorite options are not workin at the moment. Please close and reopen the app."
            return
        }
        let indexRow = imageView.tag
        
        do{
            let restaurantFromNetwork = try restaurantModel.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
            
            if(restaurantFromNetwork.isFavorite == true){
                try restaurantModel.deleteRestaurantFromFavorite(restaurant: restaurantFromNetwork)
            }else{
                alertUser = "Incorrect restaurant was about to be removed from favorite"
            }
        }
        catch RestaurantError.notAbleToDelete(let name){
            alertUser = "Not able to remove \(name) from favorite list"
        }
        catch{
            alertUser = "Unexpected Error while preparing to navigate"
         }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        guard let identifier = segue.identifier else{
            preconditionFailure("No segue identifier")
        }
        
        let segueToVC : UIViewController?
        
        switch segue.destination{
      
        case is MapViewVC :
                segueToVC = segue.destination as? MapViewVC
        case is DetailRestaurantVC:
                segueToVC = segue.destination as? DetailRestaurantVC
        default :
                print(segue.destination)
                preconditionFailure("Wrong destination type: \(segue.destination)")
        }
        
        var retaurants = RestaurantArray()
        
        switch identifier{
       
        case "singleMapSegue" :
            
            var rowNo : Int?
            
            if let button = sender as? UIButton {
                rowNo = button.tag
            }
            
            guard let indexRow = rowNo else{
                 preconditionFailure("Segue from unexpected object: \(sender ?? "sender = nil")")
            }
            
            do{
                let restaurant = try restaurantModel.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
                let place = Place()
                place.trainStop = restaurant.trainStop
                retaurants.append(restaurant)
                place.restaurants = retaurants
                
                guard let vc = segueToVC as? MapViewVC else{
                    preconditionFailure("Could not find segue")
                }
                vc.place = place
            }
            catch(RestaurantError.invalidRowSelection()){
                alertUser = "Restaurant selected could not be navigated to the map"
            }
            catch{
                alertUser = "Unexpected Error"
            }
            
        case "multipleMapSegue" :
            
            do{
                let place = Place()
                let restaurantsFetched = try restaurantModel.getAllRestaurantsFromNetwork()
                place.trainStop = restaurantsFetched.first?.trainStop
                retaurants = restaurantsFetched
                place.restaurants = retaurants
                
                guard let vc = segueToVC as? MapViewVC else{
                    preconditionFailure("Could not find segue")
                }
                vc.place = place
            }
                
            catch(RestaurantError.zeroCount()){
                alertUser = "There are no restaurants to show"
                }
            catch{
                alertUser = "Unexpected Error"
                }
            
        case "detailSegueFromHeart" :
            
                var rowNo : Int?
                
                if let imageRow = sender as? UIImageView {
                    rowNo = imageRow.tag
                }
                
                guard let indexRow = rowNo else{
                    preconditionFailure("Segue from unexpected object: \(sender ?? "sender = nil")")
                }
                guard let vc = segueToVC as? DetailRestaurantVC else{
                    preconditionFailure("Could not find segue")
                }
                
                do{
                    let restaurantFromNetwork = try restaurantModel.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
                    vc.restaurant = restaurantFromNetwork
                }
                    
                catch(RestaurantError.invalidRowSelection()){
                    alertUser = "Restaurant selected could not be navigated to the map"
                }
                catch(RestaurantError.notAbleToDelete(let name)){
                    alertUser = "Restaurant \(name) could not be removed from favorite"
                }
                catch{
                    alertUser = "Unexpected Error"
                }
                vc.restaurantDetailVCType = DetailVCType.Preload
                vc.saveDetailVC = {[weak self] (restaurant) in
                    do{
                        
                        try self?.restaurantModel.addRestaurantToFavorite(restaurantOpt: restaurant)
                    }
                    catch RestaurantError.invalidRestaurant(){
                        self?.alertUser = "Restaurant is nil"
                    }
                    catch{
                        self?.alertUser = "Something went wrong while adding"
                    }
                }
            
        default : break
        }
    }
}

extension RestaurantVC{
    
    func updateUI(){
        self.tableView.reloadData()
    }
    
    func removeRestaurantFromFavoriteSavedList(restaurant: Restaurant){
        do{
            try Persistence.delete(restaurant)
        }
        catch RestaurantError.notAbleToDelete(let name){
            alertUser = "Not able to delete \(name) from database"
        }
        catch {
            alertUser = "Unexpected Error while deletig from database"
        }
    }
}

extension RestaurantVC{
    
    @objc func heartTap(gesture : UITapGestureRecognizer){
        let imageView = gesture.view as? UIImageView
        performSegue(withIdentifier: "detailSegueFromHeart", sender: imageView)
    }
    
    @objc func favoriteHeartTap(gesture : UITapGestureRecognizer){
        let imageView = gesture.view as? UIImageView
        alertRemoveFavorite = imageView
    }
}

extension RestaurantVC{
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
    
    var alertRemoveFavorite :  UIImageView?{
        get{
            preconditionFailure("You cannot read from this object")
        }
        
        set{
            let alert = UIAlertController(title: "Remove Favorite?", message: "Do you want to remove this favorite restaurant", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {[weak self]_ in
                let imageView = newValue
                self?.removeFavorite(imageViewOpt: imageView)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}






