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

    private var model = RestaurantModel.getInstance()
    
    //Same restaurant could be selected from Network and Favorite List. So we are removing the duplicates
    private lazy var restaurantsToNotify : ()->[Restaurant] = {
        
                    let restaurantsFromNetwork = self.model.restaurantsFromNetwork.filter({$0.isSelected == true})
                    let restaurantsFromFavorite = self.model.restaurantsSaved.filter({$0.isSelected == true})
                    let totalList = restaurantsFromNetwork + restaurantsFromFavorite

                    var filterRestaurants = [Restaurant]()
                    totalList.forEach({
                        if(!filterRestaurants.contains($0)){
                            filterRestaurants.append($0)
                        }
                    })
        
                    return filterRestaurants
                }
    private var showDefaultIndexClosure : (()->Void)?
    
    override func viewDidLoad() {
        tabBarController?.delegate = self
        super.viewDidLoad()
        showImageDialog()
        
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
        
        restaurantInfo = convertToHTMLTable(restaurants: restaurantsToNotify())
        
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
        restaurantInfo = convertToMSGBody(restaurants: restaurantsToNotify())
        
        msgComposer.body = restaurantInfo
        msgComposer.messageComposeDelegate = self
        
        DispatchQueue.main.async(execute: {
            self.present(msgComposer, animated: true, completion: self.showDefaultIndexClosure)
        })
    }
    
    @objc func whatsAppClicked()
    {
        var restaurantInfo = String()
        restaurantInfo = convertToMSGBody(restaurants: restaurantsToNotify())
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
                innerHTML +=  "<td>" + restaurant.restaurantName + restaurant.displayedAddress.getTruncatedAddress(firstAddress: "", seperator: " @ ") + "</a>  </td>"

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
