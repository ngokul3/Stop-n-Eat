//
//  RestaurantCell.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/25/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit
typealias ImageLoadType = (Data, HTTPURLResponse, Error)->Void

class RestaurantCell: UITableViewCell {
    
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var btnSingleMap: UIButton!
    @IBOutlet weak var imgRail: UIImageView!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblRestaurantName: UILabel!
    @IBOutlet weak var imgRatings: UIImageView!
    @IBOutlet weak var imgHeart: UIImageView!
 
   override func awakeFromNib() {
        super.awakeFromNib()
    }
}

