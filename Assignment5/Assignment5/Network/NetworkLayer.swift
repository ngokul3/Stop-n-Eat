//
//  NetworkLayer.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/28/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation
import Alamofire


class RestaurantNetwork{
    
    func loadFromNetwork(location: String, term: String, finished: @escaping (_ dataDict: NSDictionary?, _ errorMsg: String?)  -> ()) {
        let MY_API_KEY = "Bearer qEjtERYCtGRtYmaELAxisLtdM2TWMsUbLG-wvs0b8KlxIfECiKGRrnY7AKOZwe6Zsz_DehvIAXJtt4jiIrKYjCgyf0Tx4CK_yX0u-6LpOc35By8TiyGlLdElXgqzWXYx"
        
        var locationURL : String
        locationURL = "https://api.yelp.com/v3/businesses/search?term=" + term+"&location=" + location
        
        locationURL = locationURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        if let url = URL(string: locationURL) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            
            urlRequest.addValue(MY_API_KEY, forHTTPHeaderField: "Authorization")
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
                      //  print(JSON)
                         finished(JSON, nil)
                    }
                    else{
                        finished(nil, "Json crashed")
                    }
                    
                    //guard let data = response.data else { return }
                    
                    //print(data)
                   // finished(JSON)
                    
            }
        }
        
        print("loading data from server")
        
    }
    
}
