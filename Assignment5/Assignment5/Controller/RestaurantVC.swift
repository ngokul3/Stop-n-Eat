//
//  RestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/25/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class RestaurantVC: UIViewController, UISearchBarDelegate {
   
    
    @IBOutlet weak var tableView: UITableView!
    var trainlocation : String = ""
    var cellArrray = [RestaurantCell]()
    private var model = RestaurantModel.getInstance()
    private static var modelObserver: NSObjectProtocol?

    override func viewDidLoad() {
        
        if(!trainlocation.isEmpty){
            model.loadRestaurantFromNetwork(njTransitStationCoordinates: trainlocation)
        }
        
        RestaurantVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantLoadedFromNetwork), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
        
            super.viewDidLoad()
    }
}

extension RestaurantVC{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //model.currentFilter = searchText
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // "give up focus" in HTML/JavaScript
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
extension RestaurantVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        
        print("Returned name is \(model.restaurantsFromNetwork[indexPath.row].restaurantName)")
        cell.textLabel?.text = model.restaurantsFromNetwork[indexPath.row].restaurantName
        return cell
        
        
//
//        let CellID = "restaurantCell"
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as? RestaurantCell else{
//            preconditionFailure("Incorrect cell provided -- see storyboard")
//        }
//        switch indexPath.row{
//
//        case 0:
//            cell.lblMiles.text = "2 mi"
//            cell.lblRestaurantName.text = "Dominos"
//            cell.imgRail.image = UIImage(named: "Rail.png")
//            cell.imgStar1.image = UIImage(named: "Rating.png")
//            cell.imgStar2.image = UIImage(named: "Rating.png")
//            cell.imgStar3.image = UIImage(named: "Rating.png")
//             cell.imgThumbnail.image = UIImage(named: "pizza.jpg")
//
//        case 1:
//            cell.lblMiles.text = "1 mi"
//            cell.lblRestaurantName.text = "Dosa Corner"
//            cell.imgRail.image = UIImage(named: "Rail.png")
//            cell.imgStar1.image = UIImage(named: "Rating.png")
//            cell.imgStar2.image = UIImage(named: "Rating.png")
//
//           //  cell.accessoryType = .checkmark
//        case 2:
//            cell.lblMiles.text = "3 mi"
//            cell.lblRestaurantName.text = "Chipotle"
//            cell.imgRail.image = UIImage(named: "Rail")
//            cell.imgStar1.image = UIImage(named: "Rating.png")
//
//            cell.imgThumbnail.image = UIImage(named: "chipotle.png")
//
//        default : break
//        }
//
//
//
//        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.restaurantsFromNetwork.count
    }
 }

extension RestaurantVC{
    
    func updateUI(){
        self.tableView.reloadData()
    }
}

