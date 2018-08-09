//
//  RestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/25/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class RestaurantVC: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    
    var trainStop : TrainStop?
    private var cellArrray = [RestaurantCell]()
    private var restaurantModel = AppDel.restModel
    private var notifyModel = AppDel.notifyModel
    private static var modelObserver: NSObjectProtocol?
    private var removeFavoriteNo : ((UIAlertAction, String)->Void)?
    private var shouldRemoveFavorite : Bool?
    
    lazy var isRestaurantSetToNotify : (Restaurant, Restaurant)->Bool = {(restaurantInNotify, restaurantFromNetwork) in

        if (restaurantInNotify.restaurantId == restaurantFromNetwork.restaurantId) {
            return true
         }
        else{
            return false
        }
    }
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
        
        RestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantListChanged), object: nil, queue: OperationQueue.main) {
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

extension RestaurantVC : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantCell else{
            preconditionFailure("Incorrect Cell provided")
        }
        
        var restaurantFromNetwork: Restaurant?
        
        do{
            restaurantFromNetwork = try restaurantModel.getRestaurantFromNetwork(fromRestaurantArray: indexPath.row)
        }
        catch{
            print("Unexpected Error while framing cell")
        }
        
        guard let restaurant = restaurantFromNetwork  else{
             preconditionFailure("Restaurant list did not get loaded")
        }

        cell.lblRestaurantName.text = restaurant.restaurantName
        cell.lblMiles.text = restaurant.distanceShownWithImage
        cell.btnSingleMap.tag = indexPath.row
        let ratingImageName = restaurant.ratingImageName
        cell.imgRatings.image = UIImage(named: ratingImageName)

        //Will have to check for Id and not restaurant itself because once a restaurant gets saved, the reference changes during the next invoke. When a saved restaurant is selected, I would like to display checkmark on the restaurant from Network.
        
        if(notifyModel.getRestaurantsToNotify().contains{isRestaurantSetToNotify($0, restaurant)}){
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.none

        }
        cell.imgHeart.image = UIImage(named: restaurant.favoriteImageName)
        let heartTap : UITapGestureRecognizer?
        
        if(restaurant.isFavorite){
            heartTap = UITapGestureRecognizer(target: self, action: #selector(RestaurantVC.favoriteHeartTap(gesture: )))
        }
        else{
            heartTap = UITapGestureRecognizer(target: self, action: #selector(RestaurantVC.heartTap(gesture: )))
        }
        
        if let tap = heartTap{
            cell.imgHeart.addGestureRecognizer(tap)
            cell.imgHeart.isUserInteractionEnabled = true
            cell.imgHeart.tag = indexPath.row
        }
        
        restaurantModel.loadRestaurantImage(imageURLOpt: restaurant.imageURL, imageLoaded: ({(data,response,error) in
                OperationQueue.main.addOperation {
                    if let e = error {
                        print("HTTP request failed: \(e.localizedDescription)")
                        cell.imgThumbnail.image = nil
                    }
                    else{
                        if let httpResponse = response {
                            print("http response code: \(httpResponse.statusCode)")
                            
                            let HTTP_OK = 200
                            if(httpResponse.statusCode == HTTP_OK ){
                                
                                if let imageData = data{
                                    print("urlArrivedCallback operation: Now on thread: \(Thread.current)")
                                    cell.imgThumbnail.image = UIImage(data: imageData)
                                }
                                else{
                                    cell.imgThumbnail.image = nil
                                    print("Image data not available")
                                }
                            }
                            else{
                                cell.imgThumbnail.image = nil
                                print("HTTP Error \(httpResponse.statusCode)")
                            }
                        }
                        else{
                            cell.imgThumbnail.image = nil
                            print("Can't parse imageresponse")
                        }
                    }
                }
            })
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let restaurantsFromNetwork = restaurantModel.getAllRestaurantsFromNetwork()
        return restaurantsFromNetwork.count
     }
 }

extension RestaurantVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        do{
            let restaurantFromNetwork = try restaurantModel.getRestaurantFromNetwork(fromRestaurantArray: indexPath.row)
        
            if(tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark){
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                restaurantFromNetwork.isSelected = false
                
                if(notifyModel.getRestaurantsToNotify().contains{isRestaurantSetToNotify($0, restaurantFromNetwork)}){
                    do{
                        try notifyModel.removeRestauarntFromNotification(restaurant: restaurantFromNetwork)
                    }
                    catch{
                        alertUser = "Restaurant could not be removed from notify list"
                        return
                    }
                }
            }
            else{
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                restaurantFromNetwork.isSelected = true
                notifyModel.addRestaurantToNotify(restaurantToNotify: restaurantFromNetwork)
            }
        }
        catch{
            alertUser = "Unexpected Error while selecting restaurants"
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
            }
            else{
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
        
        var restaurants = RestaurantArray()
        
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
                restaurants.append(restaurant)
                place.restaurants = restaurants
                
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
                let place = Place()
                let restaurantsFetched = restaurantModel.getAllRestaurantsFromNetwork()
                place.trainStop = restaurantsFetched.first?.trainStop
                place.restaurants = restaurantsFetched
                
                guard let vc = segueToVC as? MapViewVC else{
                    preconditionFailure("Could not find segue")
                }
                
                vc.place = place
            
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






