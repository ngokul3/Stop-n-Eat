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

    
    override func viewDidLoad() {
        tabBarController?.delegate = self
        super.viewDidLoad()
        
        
        
        showImageDialog()
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        
        showImageDialog()
        print("Inside didSeelct")
    }


}
extension NotifyVC: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    func showImageDialog(animated: Bool = true) {
        
        // Prepare the popup assets
        let title = "Let's go!"
        let message = "Send your chosen places to your friend(s)"
        let image = UIImage(named: "GreenInvite.png")
        
        let popup = PopupDialog(title: title, message: message, image: image)
        
        let buttonOne = CancelButton(title: "CANCEL") {
            //self.label.text = "You canceled the Invite."
        }
        
        buttonOne.addTarget(self, action:#selector(self.cancelClicked), for: .touchUpInside)
        
        let buttonTwo = DefaultButton(title: "Send a Mail") {
            //   self.label.text = "Email"
        }
        
        buttonTwo.addTarget(self, action:#selector(self.mailClicked), for: .touchUpInside)
        
        let buttonThree = DefaultButton(title: "Send a Message") {
            //    self.label.text = "Message)"
        }
        
        buttonThree.addTarget(self, action:#selector(self.messageClicked), for: .touchUpInside)
        
        
        
        let buttonFour = DefaultButton(title: "WhatsApp") {
            //    self.label.text = "Message)"
        }
        
        buttonFour.addTarget(self, action:#selector(self.whatsAppClicked), for: .touchUpInside)
        
        
        popup.addButtons([buttonOne, buttonTwo, buttonThree, buttonFour])
        
        self.present(popup, animated: animated, completion: nil)
        
    }
    
    
    @objc func cancelClicked()
    {
        self.dismiss(animated: true, completion: nil)
        tabBarController!.selectedIndex = 0
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func mailClicked()
    {
        if !MFMailComposeViewController.canSendMail() {
            #if targetEnvironment(simulator)
                alertUser = "Application should be running in device to send mail"
            #else
                print("Real device")
            #endif
            
            return
        }
        let mailComposer = MFMailComposeViewController()
        
        var businessInfo = String()
        
       // businessInfo = ConvertToHTMLTable(businessSelected: businesses.filter({$0.selected == true}))
        
        mailComposer.setMessageBody(businessInfo, isHTML: true)
        mailComposer.setSubject("Check out these locations that we can go")
        mailComposer.mailComposeDelegate = self
        
        
        DispatchQueue.main.async(execute: {
            self.present(mailComposer, animated: true, completion: nil)
        })
        
        
    }
    
    @objc func messageClicked()
    {
        if !MFMessageComposeViewController.canSendText(){
            #if targetEnvironment(simulator)
                alertUser = "Application should be running in device to send message"
            #else
                print("Real device")
            #endif
            return
       }
        
        let msgComposer = MFMessageComposeViewController()
        var businessInfo  = String()
        
        //businessInfo = ConvertToMSGBody(businessSelected: businesses.filter({$0.selected == true}))
        
        msgComposer.body = businessInfo
        msgComposer.messageComposeDelegate = self
        
        DispatchQueue.main.async(execute: {
            self.present(msgComposer, animated: true, completion: nil)
        })
        
    }
    
    @objc func whatsAppClicked()
    {
        var businessInfo  = String()
       // businessInfo = ConvertToMSGBody(businessSelected: businesses.filter({$0.selected == true}))
        
        let urlWhats = "whatsapp://send?text=\(businessInfo)"
        
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            if let whatsappURL = NSURL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    UIApplication.shared.open(whatsappURL as URL, options : [:] , completionHandler: nil)
                } else {
                    
                    #if targetEnvironment(simulator)
                    alertUser = "WhatsApp is not available on this device"
                    #else
                    print("Real device")
                    #endif
                    return
                        
                    print("please install watsapp")
                }
            }
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith: MFMailComposeResult, error: Error?)
    {
        self.dismiss(animated: true, completion: nil)
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
                                            self?.tabBarController!.selectedIndex = 0
                                            })
                                        )
                        )
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
            
        }
    }
}
