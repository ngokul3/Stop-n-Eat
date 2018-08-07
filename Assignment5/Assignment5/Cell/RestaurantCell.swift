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
    @IBOutlet weak var imgAnnotation: UIImageView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var btnSingleMap: UIButton!
    @IBOutlet weak var imgRail: UIImageView!
    @IBOutlet weak var lblMiles: UILabel!
    @IBOutlet weak var lblRestaurantName: UILabel!
    @IBOutlet weak var imgRatings: UIImageView!
    @IBOutlet weak var imgHeart: UIImageView!
    
    lazy var imageLoaderClosure: ((Data?, HTTPURLResponse?, Error?)-> Void) = {[weak self](data, response, error) in
        if let e = error {
            print("HTTP request failed: \(e.localizedDescription)")
        }
        else{
            if let httpResponse = response {
                print("http response code: \(httpResponse.statusCode)")
                
                let HTTP_OK = 200
                if(httpResponse.statusCode == HTTP_OK ){
                    
                    if let imageData = data{
                        OperationQueue.main.addOperation {
                            print("urlArrivedCallback operation: Now on thread: \(Thread.current)")
                            self?.imgThumbnail.image = UIImage(data: imageData)
                        }
                    }else{
                        print("Image data not available")
                    }
                    
                }else{
                    print("HTTP Error \(httpResponse.statusCode)")
                }
            }else{
                print("Can't parse imageresponse")
            }
        }
    }
   override func awakeFromNib() {
        super.awakeFromNib()
    }
}

