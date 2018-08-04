//
//  NotifyCell.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 8/4/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class NotifyCell: UITableViewCell {

    @IBOutlet weak var imgRestaurantNotify: UIImageView!
    @IBOutlet weak var lblRestaurantDescription: UILabel!
    
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
                            self?.imgRestaurantNotify.image = UIImage(data: imageData)
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
        // Initialization code
    }



}
