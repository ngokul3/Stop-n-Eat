//
//  RestaurantCell.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/25/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class RestaurantCell: UITableViewCell {
    @IBOutlet weak var imgAnnotation: UIImageView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var btnSingleMap: UIButton!
    @IBOutlet weak var imgRail: UIImageView!

    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblRestaurantName: UILabel!
    @IBOutlet weak var imgRatings: UIImageView!
    @IBOutlet weak var imgHeart: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

 

}