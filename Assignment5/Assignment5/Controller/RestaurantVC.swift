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
    var cellArrray = [RestaurantCell]()
    private var model = RestaurantModel.getInstance()
    private static var modelObserver: NSObjectProtocol?

    override func viewDidLoad() {
        
        guard let stop = trainStop else{
            preconditionFailure("Could not find Stop")
        }
        
        model.loadRestaurantFromNetwork(trainStop: stop)
     
        RestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantLoadedFromNetwork), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
        
//        RestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantRefreshed), object: nil, queue: OperationQueue.main) {
//
//            [weak self] (notification: Notification) in
//            if let s = self {
//                let info0 = notification.userInfo?[Consts.KEY0]
//
//                let restaurantOpt = info0 as? Restaurant
//
//                guard let restaurant = restaurantOpt else{
//                    preconditionFailure("Could not save this favorite restaurant")
//                }
//
//                s.saveRestaurant(restaurant)
//            }
//        }
        
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
            let _ = try model.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
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
        
        print("Returned name is \(model.restaurantsFromNetwork[indexPath.row].restaurantName)")
        cell.lblRestaurantName.text = model.restaurantsFromNetwork[indexPath.row].restaurantName
        cell.btnSingleMap.tag = indexPath.row
        cell.btnHeart.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.restaurantsFromNetwork.count
    }
 }

extension RestaurantVC{
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
                let restaurant = try model.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
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
                let restaurantsFetched = try model.getAllRestaurantsFromNetwork()
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
                    let restaurantFromNetwork = try model.getRestaurantFromNetwork(fromRestaurantArray: indexRow)
                    vc.restaurant = restaurantFromNetwork
                }
                    
                catch(RestaurantError.invalidRowSelection()){
                    alertUser = "Restaurant selected could not be navigated to the map"
                }
                    
                catch{
                    alertUser = "Unexpected Error"
                }
                
                
                vc.restaurantDetailVCType = DetailVCType.Preload
                vc.saveDetailVC = {[weak self] (restaurant) in
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

}

