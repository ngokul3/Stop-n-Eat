//
//  DetailRestaurantVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/29/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class DetailRestaurantVC: UIViewController {

    @IBOutlet weak var dateVisited : UIDatePicker!
    @IBOutlet weak var lblRestaurantName: UILabel!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var imgRating1: UIImageView!
    @IBOutlet weak var imgRating2: UIImageView!
    @IBOutlet weak var imgRating3: UIImageView!
    @IBOutlet weak var imgRating4: UIImageView!
    @IBOutlet weak var imgRating5: UIImageView!
    
    var restaurant : Restaurant?
    var goBackAction : ((UIAlertAction) -> Void)?
    var restaurantDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        txtNotes.layer.borderColor = UIColor.gray.cgColor
        txtNotes.layer.borderWidth = 0.4
        txtNotes.layer.cornerRadius = 0.8
        
        guard let detailType = restaurantDetailVCType else
        {
            preconditionFailure("Parent VC did not initialize Detail VC Type")
            
        }
        
        if(detailType == .Preload)
        {
            guard let restaurantInContext = restaurant else
            {
                preconditionFailure("Parent VC did not initialize MenuItem")
            }
            
            lblRestaurantName.text = restaurantInContext.restaurantName
            dateVisited.date = restaurantInContext.dateVisited
            txtNotes.text = "Prepopulate with distance from station" //todo
        }
    }
}

extension DetailRestaurantVC{
    @IBAction func btnSavedClicked(_ sender: UIBarButtonItem) {
        saveDetailVC?(restaurant)
    }
    
}
