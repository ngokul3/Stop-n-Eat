//
//  NetworkLayer.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/28/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import Foundation
import Alamofire

//Todo train and rest protocol here
protocol NetworkProtocol {
    static func getInstance() -> NetworkProtocol
    func loadFromNetwork(location: String, term: String, finished: @escaping (_ dataDict: NSDictionary?, _ errorMsg: String?)  -> ())
    func setRestaurantImage(forRestaurantImage restaurantImageURL : String, imageLoaded : @escaping (Data?, HTTPURLResponse?, Error?)->Void)
}
    
//protocol NetworkImageListener{
//   func setRestaurantImage(forRestaurantImage restaurantImageURL : String, imageLoaded : @escaping (Data?, HTTPURLResponse?, Error?)->Void)
//}
class NetworkModel: NetworkProtocol{
    
    private var keyOpt : String?
    private static var instance: NetworkProtocol?
    
    var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        return session
    }()
    
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
}

extension NetworkModel{
    static func getInstance() -> NetworkProtocol {
        if let inst = NetworkModel.instance {
            return inst
        }
        
        let inst = NetworkModel()
        NetworkModel.instance = inst
        return inst
    }
}
//todo remove term from below func
extension NetworkModel{
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
    
    func setRestaurantImage(forRestaurantImage restaurantImageURL : String, imageLoaded : @escaping (Data?, HTTPURLResponse?, Error?)->Void) {
        
        if let _ = URL(string: restaurantImageURL)
        {
            let restaurantImageURL = URL(string: restaurantImageURL)!
            let downloadPicTask = session.dataTask(with: restaurantImageURL) { (data, responseOpt, error) in
                if let e = error {
                    print("Error downloading cat picture: \(e)")
                } else {
                    if let response = responseOpt as? HTTPURLResponse {
                        
                        if let imageData = data {
                            imageLoaded(imageData, response, error)
                            // Finally convert that Data into an image and do what you wish with it.
//                            DispatchQueue.main.async(execute: {
//
//                                self.imgBusiness.image = UIImage(data: imageData)
//                            })
                            
                        } else {
                            imageLoaded(nil, response, error)
                        }
                    }else {
                        imageLoaded(nil, nil, error)
                    }
                }
            }
            downloadPicTask.resume()
            
        }
    }
    
}
