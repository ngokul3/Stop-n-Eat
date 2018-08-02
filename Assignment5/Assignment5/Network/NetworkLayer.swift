//
//  NetworkLayer.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/28/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation
import Alamofire

//Todo key should come from info.plist

class RestaurantNetwork{
    
    private var keyOpt : String?
    
    init()
    {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
           
            let dictRootOpt = NSDictionary(contentsOfFile: path)
           
            guard let dict = dictRootOpt else{
                preconditionFailure("Yelp API is not available")
            }
                keyOpt = dict["YelpAPIKEY"] as? String
        }
    }

    func loadFromNetwork(location: String, term: String, finished: @escaping (_ dataDict: NSDictionary?, _ errorMsg: String?)  -> ()) {
        guard let myKey = keyOpt else{
            return
        }
        print("Searching for location \(location)")
        
        var locationURL : String
        locationURL = "https://api.yelp.com/v3/businesses/search?term=" + term+"&location=" + location
        
        locationURL = locationURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        if let url = URL(string: locationURL) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            
            urlRequest.addValue(myKey, forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            
            Alamofire.request(urlRequest)
                .responseJSON { response in
                    debugPrint(response)
                    
                    if let status = response.response?.statusCode {
                        switch(status){
                        case 201:
                            print("success")
                        default:
                            print("Response status: \(status)")
                        }
                    }
                    
                    if let result = response.result.value {
                        let JSON = result as? NSDictionary
                         finished(JSON, nil)
                    }
                    else{
                        finished(nil, "Json crashed")
                    }
            }
        }
        
        print("loading data from server")
        
    }
    
}
