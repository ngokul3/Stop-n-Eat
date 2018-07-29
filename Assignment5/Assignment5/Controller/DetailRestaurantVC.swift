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
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    var restaurant : Restaurant?
    var goBackAction : ((UIAlertAction) -> Void)?
    var menuDetailVCType : DetailVCType?
    var saveDetailVC: ((Restaurant?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

    }


}
