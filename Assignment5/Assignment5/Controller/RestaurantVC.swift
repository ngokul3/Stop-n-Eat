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
    private var networkModel = AppDel.networkModel
    private static var modelObserver: NSObjectProtocol?
    var removeFavoriteNo : ((UIAlertAction)->Void)?
    
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
        
//        removeFavoriteNo = ({[weak self](arg) -> Void in
//            //self?.shouldRemoveFavorite = false
//        })
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
        cell.btnHeart.tag = indexPath.row
        cell.btnHeart.setBackgroundImage(UIImage(named: restaurant.favoriteImageName), for: .normal)
        cell.btnHeart.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        let rating = restaurant.givenRating
        let imageName = "\(rating)Stars"
        cell.imgRatings.image = UIImage(named: imageName)
        
        //Todo put the below in a closure separately
        networkModel.setRestaurantImage(forRestaurantImage: restaurant.imageURL, imageLoaded: ({(data,response,error) in
            
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
                                    cell.imgThumbnail.image = UIImage(data: imageData)
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
        
            })
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantModel.restaurantsFromNetwork.count
    }
 }

extension RestaurantVC{
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier{
        
        case "detailSegue":
            var rowNo : Int?
            
            if let button = sender as? UIButton {
                rowNo = button.tag
            }
            
            guard let indexRow = rowNo else{
                preconditionFailure("Segue from unexpected object: \(sender ?? "sender = nil")")
            }
            do{
                let restaurantFromNetwork = try restaurantModel.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
                
                if(restaurantFromNetwork.isFavorite == true){
                    //Todo
                    //alertRemoveFavorite = "Do you want to remove \(restaurantFromNetwork.restaurantName) from Favorite"
//                    if(shouldRemoveFavorite != nil){
//                        return false
//                    }else{
//                        shouldRemoveFavorite = nil
//                    }
   
                    try restaurantModel.deleteRestaurantFromFavorite(restaurant: restaurantFromNetwork)
                    return false
                }else
                {
                    return true
                }
            }
            catch RestaurantError.notAbleToDelete(let name){
                alertUser = "Not able to delete \(name)"
                return false
            }
            catch{
                alertUser = "Unexpected Error while preparing to navigate"
                return false
            }
        
        default:    return true
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
            
        case "detailSegue" :
            
                var rowNo : Int?
                
                if let button = sender as? UIButton {
                    rowNo = button.tag
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
    
    var alertRemoveFavorite :  String{
        get{
            preconditionFailure("You cannot read from this object")
        }
        
        set{
            let alert = UIAlertController(title: "Remove Favorite?", message: newValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "No ", style: .default, handler: self.removeFavoriteNo))
            
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
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
}



