//
//  RestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/25/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class RestaurantVC: UIViewController {
    
    var cellArrray = [RestaurantCell]()
            override func viewDidLoad() {
            super.viewDidLoad()
    }
}

extension RestaurantVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let CellID = "restaurantCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as? RestaurantCell else{
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
             cell.imgThumbnail.image = UIImage(named: "pizza.jpg")
      //      cell.imgInfo.image = UIImage(named: "savedHeart.png")
            
        case 1:
            cell.lblMiles.text = "3.1 mi"
            cell.lblRestaurantName.text = "Dosa Corner"
            cell.imgRail.image = UIImage(named: "Rail.png")
            cell.imgStar1.image = UIImage(named: "Rating.png")
            cell.imgStar2.image = UIImage(named: "Rating.png")
            cell.imgThumbnail.image = UIImage(named: "dosa.ipg")
       //     cell.imgInfo.image = UIImage(named: "savedHeart.png")
             cell.accessoryType = .checkmark
        case 2:
            cell.lblMiles.text = "3 mi"
            cell.lblRestaurantName.text = "Chipotle"
            cell.imgRail.image = UIImage(named: "Rail")
            cell.imgStar1.image = UIImage(named: "Rating.png")
         //    cell.imgInfo.image = UIImage(named: "heart.png")
            
            cell.imgThumbnail.image = UIImage(named: "chipotle.png")
           
        default : break
        }
       
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
 }

