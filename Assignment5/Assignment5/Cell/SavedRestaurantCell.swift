//
//  SavedRestaurantCellTableViewCell.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/26/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class SavedRestaurantCell: UITableViewCell {

    @IBOutlet weak var txtDateSaved: UILabel!
    @IBOutlet weak var txtNotesRestaurant: UITextView!
    @IBOutlet weak var imgRail: UIImageView!
    @IBOutlet weak var imgStar1: UIImageView!
    @IBOutlet weak var imgStar2: UIImageView!
    @IBOutlet weak var imgStar3: UIImageView!
    @IBOutlet weak var imgStar4: UIImageView!
    @IBOutlet weak var imgStar5: UIImageView!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblRestaurantName: UILabel!
    
    override func awakeFromNib() {
        txtNotesRestaurant.layer.borderColor = UIColor.gray.cgColor
        txtNotesRestaurant.layer.borderWidth = 0.4
        txtNotesRestaurant.layer.cornerRadius = 0.8
        
        super.awakeFromNib()
    }
}
