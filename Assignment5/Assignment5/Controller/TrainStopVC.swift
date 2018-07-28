//
//  ViewController.swift
//  Assignment5
//
//  Created by Gokula K Narasimhan on 7/24/18.
//  Copyright © 2018 Gokula K Narasimhan. All rights reserved.
//

import UIKit

class TrainStopVC: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var searchBar: UISearchBar!
   
    @IBOutlet weak var tableView: UITableView!
    private var model = TrainStopModel.getInstance()
    private static var modelObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
       
        TrainStopVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.StopListFiltered), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
        
        
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
        if(model.currentFilter != searchText){
             model.currentFilter = searchText
        }
      
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() 
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
       return model.filteredStops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "trainCell", for: indexPath)
        cell.textLabel?.text = model.filteredStops[indexPath.row].stopName
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
    }

}

extension TrainStopVC{
    func updateUI(){
        self.tableView.reloadData()
        
//        if(searchBar.text != model.currentFilter)
//        {
//            searchBar.text = model.currentFilter
//        }
         // print(searchBar.text)
    }
}
