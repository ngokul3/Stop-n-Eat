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

        // Do any additional setup after loading the view.
    }


}

extension SavedRestaurantVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellID = "savedRestaurantCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as? SavedRestaurantCell else{
            preconditionFailure("Incorrect cell provided -- see storyboard")
        }
        switch indexPath.row{
            
        case 0:
            cell.lblMiles.text = "2 mi"
            cell.lblRestaurantName.text = "Dominos"
            cell.imgRail.image = UIImage(named: "Rail.png")
            cell.imgStar1.image = UIImage(named: "Rating.png")
            cell.imgStar2.image = UIImage(named: "Rating.png")
            cell.imgStar3.image = UIImage(named: "Rating.png")
            cell.txtNotesRestaurant.text = "Yelp gave 3 R. Service is good"
            cell.txtDateSaved.text = "07/01/2018"
        case 1:
            cell.lblMiles.text = "3.1 mi"
            cell.lblRestaurantName.text = "Dosa Corner"
            cell.imgRail.image = UIImage(named: "Rail.png")
            cell.imgStar1.image = UIImage(named: "Rating.png")
            cell.imgStar2.image = UIImage(named: "Rating.png")
             cell.txtNotesRestaurant.text = "Mint Sauce is not spicy enough"
             cell.txtDateSaved.text = "05/03/2018"
        case 2:
            cell.lblMiles.text = "3 mi"
            cell.lblRestaurantName.text = "Chinese Bowl"
            cell.imgRail.image = UIImage(named: "Rail")
            cell.imgStar1.image = UIImage(named: "Rating.png")
             cell.txtNotesRestaurant.text = "Noodles was not enough"
             cell.txtDateSaved.text = "07/11/2018"
        default : break
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
