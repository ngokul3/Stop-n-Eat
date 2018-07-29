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
        cell.txtNotesRestaurant.text = restaurant.comments
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.restaurantsSaved.count
    }
}

extension SavedRestaurantVC{
    func updateUI()
    {
        tableView.reloadData()
    }
}
