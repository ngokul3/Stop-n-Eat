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
    private var stopLocation : String = "" // Todo - can be put into View state
    private var model = TrainStopModel.getInstance()
    private static var modelObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
       
        TrainStopVC.modelObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:   Messages.StopListFiltered), object: nil, queue: OperationQueue.main) {
            
            [weak self] (notification: Notification) in
            if let s = self {
                s.updateUI()
            }
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
}

extension TrainStopVC{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        guard let _ = segue.identifier else{
//            preconditionFailure("No segue identifier")
//        }
        
        guard let segueVC = segue.destination as? RestaurantVC else{
            preconditionFailure("Wrong destination type: \(segue.destination)")
        }
        
        guard let cell = sender as? UITableViewCell
            ,let indexPath = self.tableView.indexPath(for: cell) else{
                preconditionFailure("Segue from unexpected object: \(sender ?? "sender = nil")")
        }
        
        do{
            let trainStop = try model.getTrainStop(fromFilteredArray: indexPath.row)
            let trainLocation = (trainStop.latitude, trainStop.longitude)
            let trainStopName = trainStop.stopName
            
            guard trainLocation.0 != 0.0
                , trainLocation.1 != 0.0 else{
                preconditionFailure("Could not find Stop location")
            }
            
            stopLocation = String(describing: trainLocation.0) + "," +  String(describing: trainLocation.1)
            
            print("Stop \(trainStopName) location returned is " + String(describing: stopLocation))
        }
        catch(TrainStopError.invalidRowSelection()){
            alertUser = "Not able to navigate to Restaurant screen"
        }
        catch{
            alertUser = "Unexpected Error"
        }
    
        guard !stopLocation.isEmpty else{
            preconditionFailure("Could not find Stop location")
        }
        segueVC.trainlocation = stopLocation
        
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
    
    var alertUser :  String{
        get{
            preconditionFailure("You cannot read from this object")
        }
        
        set{
            let alert = UIAlertController(title: "Attention", message: newValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
}

