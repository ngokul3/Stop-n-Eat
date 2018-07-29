//
//  SavedRestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/26/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class SavedRestaurantVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            
            let defaults = UserDefaults.standard
            
            guard let restObject = defaults.object(forKey: "restaurants") as? Data else{
               // print("Got the wrong type: \(type(of: rest)), giving up on restoring")
                return
            }
            let restaurants = NSKeyedUnarchiver.unarchiveObject(with: restObject) as? [Restaurant]
           // let restoredObject = try Persistence.restore()
//            guard let rest = restoredObject as? Restaurant else {
//                print("Got the wrong type: \(type(of: restoredObject)), giving up on restoring")
//                return
//            }
            print("success!: restaurant name :  \(restaurants?.first?.restaurantName)")
        }
        catch let nse as NSError {
            // First time run: nothing was saved from before
            print("Probably first run. No archived model. Error: \(nse.localizedDescription) No obj found, saving")
           // saveObject()
        }
    }


}

extension SavedRestaurantVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellID = "savedRestaurantCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as? SavedRestaurantCell else{
            preconditionFailure("Incorrect cell provided -- see storyboard")
        }
//        switch indexPath.row{
//
//        case 0:
//             cell.lblRestaurantName.text = "Dominos"
//            cell.imgStar1.image = UIImage(named: "Rating.png")
//            cell.imgStar2.image = UIImage(named: "Rating.png")
//            cell.imgStar3.image = UIImage(named: "Rating.png")
//            cell.txtNotesRestaurant.text = "10 mins walk from SH. Yelp gave 3 stars. Service is good"
//            cell.txtDateSaved.text = "07.01.18"
//        case 1:
//            cell.lblRestaurantName.text = "Dosa Corner"
//            cell.imgStar1.image = UIImage(named: "Rating.png")
//            cell.imgStar2.image = UIImage(named: "Rating.png")
//             cell.txtNotesRestaurant.text = "Mint Sauce is not spicy enough"
//             cell.txtDateSaved.text = "05.03.18"
//        case 2:
//            cell.lblRestaurantName.text = "Chinese Bowl"
//            cell.imgStar1.image = UIImage(named: "Rating.png")
//             cell.txtNotesRestaurant.text = "Noodles was not enough"
//             cell.txtDateSaved.text = "07.11.18"
//        default : break
//        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
