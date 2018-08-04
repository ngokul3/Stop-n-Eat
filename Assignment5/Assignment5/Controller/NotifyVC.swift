//
//  NotifyVC.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/26/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit
import Foundation
import MessageUI
import SafariServices
import PopupDialog

class NotifyVC: UIViewController, UITabBarControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    private var model = RestaurantModel.getInstance()
    private var notifyModel = NotifyModel.getInstance()
  //  private var model = RestaurantModel.getInstance()
    
    private static var modelObserver: NSObjectProtocol?

    //Same restaurant could be selected from Network and Favorite List. So we are removing the duplicates
 //   private lazy var restaurantsToNotify = {[weak self] in
        
//                    let restaurantsFromNetwork = self.model.restaurantsFromNetwork.filter({$0.isSelected == true})
//                    let restaurantsFromFavorite = self.model.restaurantsSaved.filter({$0.isSelected == true})
//                    let totalList = restaurantsFromNetwork + restaurantsFromFavorite
//
//                    var filterRestaurants = [Restaurant]()
//                    totalList.forEach({
//                        if(!filterRestaurants.contains($0)){
//                            filterRestaurants.append($0)
//                        }
//                    })
        
                   // return self?.notifyModel.getRestaurantsToNotify()
   //             }()
    
  
    private var showDefaultIndexClosure : (()->Void)?
    
    override func viewDidLoad() {
        tabBarController?.delegate = self
        super.viewDidLoad()
        
        NotifyVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.RestaurantNotificationListChanged), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
        
       // showImageDialog()
        
        showDefaultIndexClosure = {[weak self] in
            guard let tabBC = self?.tabBarController else{
                return
            }
            tabBC.selectedIndex = 0
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        
         if(tabBarController.selectedIndex == 2){
            showImageDialog()
        }
    }
}

//todo - image lods on custom added favorite - bug??
extension NotifyVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notifyModel.getRestaurantsToNotify().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let restaurants = notifyModel.getRestaurantsToNotify()
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "notifyCell", for: indexPath) as? NotifyCell else{
            preconditionFailure("Incorrect Cell provided")
        }
        
        if(restaurants[indexPath.row]){
            let restaurant = restaurants[indexPath.row]
            cell.lblRestaurantDescription.text = restaurant.restaurantName
            
            if(!restaurant.imageURL.isEmpty){
                AppDel.restModel.loadRestaurantImage(imageURLOpt: restaurant.imageURL, imageLoaded: ({(data, response, error) in
                    cell.imageLoaderClosure(data, response, error)
                }))
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        let restaurants = notifyModel.getRestaurantsToNotify()
        
        if editingStyle == .delete {
            
            guard  restaurants[indexPath.row] else{
                preconditionFailure("Error while getting value from the Menu Model")
            }
            
            let restaurantInContext = restaurants[indexPath.row]
            
            do{
                try notifyModel.removeRestauarntFromNotification(restaurant: restaurantInContext)
            }
                
            catch RestaurantError.notAbleToDelete(let name){
                alertUser = "\(name) cannot be deleted"
            }
                
            catch{
                alertUser = "Unexpected Error"
            }
        }
    }
}

extension NotifyVC: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    func showImageDialog(animated: Bool = true) {
        
        let title = "Places of Interests"
        let message = "Send your chosen places to your friend(s)"
        let image = UIImage(named: "") //Todo
        
        let popup = PopupDialog(title: title, message: message, image: image)
        
        let buttonOne = CancelButton(title: "CANCEL") {
        }
        
        buttonOne.addTarget(self, action:#selector(self.cancelClicked), for: .touchUpInside)
        
        let buttonTwo = DefaultButton(title: "Send a Mail") {
        }
        
        buttonTwo.addTarget(self, action:#selector(self.mailClicked), for: .touchUpInside)
        
        let buttonThree = DefaultButton(title: "Send a Message") {
        }
        
        buttonThree.addTarget(self, action:#selector(self.messageClicked), for: .touchUpInside)
        
        let buttonFour = DefaultButton(title: "WhatsApp") {
        }
        
        buttonFour.addTarget(self, action:#selector(self.whatsAppClicked), for: .touchUpInside)
        popup.addButtons([buttonOne, buttonTwo, buttonThree, buttonFour])
        
        self.present(popup, animated: animated, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: self.showDefaultIndexClosure)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith: MFMailComposeResult, error: Error?)
    {
        self.dismiss(animated: true, completion: self.showDefaultIndexClosure)
    }
}

extension NotifyVC{
    func updateUI(){
        self.tableView.reloadData()
    }
}

extension NotifyVC{
    
    @objc func cancelClicked(){
        
        self.dismiss(animated: true, completion: nil)
        guard let tabBC = tabBarController else{
            return
        }
        tabBC.selectedIndex = 0
    }
    
    @objc func mailClicked(){
        
        if !MFMailComposeViewController.canSendMail() {
            #if targetEnvironment(simulator)
                alertUser = "Application should be running in an actual device to send mails"
            #else
                print("Real device")
            #endif
            
            return
        }
        let mailComposer = MFMailComposeViewController()
        var restaurantInfo = String()
        
        let restaurants = notifyModel.getRestaurantsToNotify()
        restaurantInfo = convertToHTMLTable(restaurants: restaurants)
        
        mailComposer.setMessageBody(restaurantInfo, isHTML: true)
        mailComposer.setSubject("Hi")
        mailComposer.mailComposeDelegate = self
        
        DispatchQueue.main.async(execute: {
            self.present(mailComposer, animated: true, completion: self.showDefaultIndexClosure)
        })
    }
    
    @objc func messageClicked(){
        if !MFMessageComposeViewController.canSendText(){
            #if targetEnvironment(simulator)
                alertUser = "Application should be running in an actual device to send messages"
            #else
                print("Real device")
            #endif
            return
       }
        
        let msgComposer = MFMessageComposeViewController()
        var restaurantInfo = String()
        
        let restaurants = notifyModel.getRestaurantsToNotify()
        restaurantInfo = convertToMSGBody(restaurants: restaurants)
        
        msgComposer.body = restaurantInfo
        msgComposer.messageComposeDelegate = self
        
        DispatchQueue.main.async(execute: {
            self.present(msgComposer, animated: true, completion: self.showDefaultIndexClosure)
        })
    }
    
    @objc func whatsAppClicked()
    {
        var restaurantInfo = String()
        
        let restaurants = notifyModel.getRestaurantsToNotify()
        restaurantInfo = convertToMSGBody(restaurants: restaurants)
        
        let urlWhats = "whatsapp://send?text=\(restaurantInfo)"
        
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = NSURL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    UIApplication.shared.open(whatsappURL as URL, options : [:] , completionHandler: nil)
                } else {
                    
                    #if targetEnvironment(simulator)
                    alertUser = "WhatsApp is not available on this device."
                    #else
                    print("Real device")
                    #endif
                    return
                }
            }
        }
    }
   
 }

extension NotifyVC{
    var alertUser :  String{
        get{
            preconditionFailure("You cannot read from this object")
        }
        
        set{
            let alert = UIAlertController(title: "Attention", message: newValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel,
                                          handler: ({[weak self]_ in
                                            
                                                if let tabBC = self?.tabBarController{
                                                tabBC.selectedIndex = 0
                                                }
                                            })
                                        )
                        )
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
            
        }
    }
}

extension NotifyVC{
    func convertToHTMLTable(restaurants : [Restaurant]) -> String
    {
        var itemCount = 1
        var innerHTML = String()
        let htmlHeader = """
                <!DOCTYPE>
                <HTML>
                    <head>
                    </head>
                    <body>
                        <table>
                        

            """
        let htmlFooter = """
                       
                        </table>
                    </body>
                </HTML>
            """
        
        for restaurant in restaurants {
            innerHTML += "<tr>"
            innerHTML += "<td> " + String(itemCount) + ") " + "</td>"
            
            if(restaurant.restaurantURL.isEmpty){
                innerHTML +=  "<td>" + restaurant.restaurantName + "</td>"

            }else{
            innerHTML +=  "<td><a href=" + restaurant.restaurantURL + ">" + restaurant.restaurantName + restaurant.displayedAddress.getTruncatedAddress(firstAddress: "", seperator: " @ ") + "</a>  </td>"
            }
            
            innerHTML += "</tr>"
            itemCount = itemCount + 1
        }
        
        let html  = htmlHeader + innerHTML + htmlFooter
        
        print(html)
        return html
    }
    
    func convertToMSGBody(restaurants : [Restaurant])-> String{
        
        var itemCount = 1
        var innerMSGBody = String()
        for restaurant in restaurants {
            innerMSGBody += String(itemCount) + ") "
            
            innerMSGBody +=  restaurant.restaurantName
            if(restaurant.displayedAddress.count > 1){
                let truncatedAddress = restaurant.displayedAddress.getTruncatedAddress(firstAddress: "", seperator: " @ ")
                innerMSGBody +=  truncatedAddress
            }
            innerMSGBody += "\n"
            itemCount = itemCount + 1
        }
        return innerMSGBody
    }
}
