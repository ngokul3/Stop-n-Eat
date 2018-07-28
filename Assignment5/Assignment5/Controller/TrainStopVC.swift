//
//  ViewController.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/24/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class TrainStopVC: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var tableView: UITableView!
    private var model = TrainStopModel.getInstance()
    
    var sourceArr = ["East Orange","Millburn Train Station","Maplewood","Short Hills Train Station","Secaucus","Brampton","New Province"]
    
    override func viewDidLoad() {
       
//                DispatchQueue.global(qos: .background).async {
//                    //background code
//                    DispatchQueue.main.async {
//                        //your main thread
//                    }
//                }
        
        do{
            try model.loadTransitData(JSONFileFromAssetFolder: "RailStop", completed: {_ in })
        }
        
        catch{}//Todo do something
       
        super.viewDidLoad()
        
        
    }
}
extension TrainStopVC{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model.currentFilter = searchText
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // "give up focus" in HTML/JavaScript
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
extension TrainStopVC{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return sourceArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath)
        cell.textLabel?.text = sourceArr[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
     
       
        
    }

}
