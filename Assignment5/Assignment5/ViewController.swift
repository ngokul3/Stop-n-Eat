//
//  ViewController.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/24/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var sourceArr = ["Hoboken Train Station","Millburn","Newark","Short Hills"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return sourceArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        //        if let menuItems = menuItemsInBill {
        //            let arr = menuItems
        //            let row = indexPath.row
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        //            cell.textLabel?.text = arr[row].itemdescription
        //            return cell
        //        }
        //        else{
        //            preconditionFailure("Cell Identifier not set")
        //        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath)
        cell.textLabel?.text = sourceArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print("Table row: \(indexPath.row) was selected")
      //  tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }

    
   
    
}
