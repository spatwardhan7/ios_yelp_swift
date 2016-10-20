//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc  protocol FiltersViewControllerDelegate{
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , SwitchCellDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var categories : [[String:String]]!
    var switchStates = [Int:Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSearchButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
        var filters = [String: AnyObject]()
        
        var selectedCategories = [String]()
        for (row,isSelected) in switchStates {
            if isSelected{
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        
        
        delegate?.filtersViewController!(filtersViewController: self, didUpdateFilters: filters)
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        
        cell.switchLabel.text = categories[indexPath.row]["name"]
        cell.delegate = self
        
        if switchStates[indexPath.row] != nil {
            cell.onSwitch.isOn = switchStates[indexPath.row]!
        }else {
            cell.onSwitch.isOn = false
        }
        
        
        
        return cell
    }
    
    func switchCell(switchcell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchcell)
        
        switchStates[(indexPath?.row)!] = value
        print("filters view controller got the switch event")
    }
    
    func yelpCategories() -> [[String: String]]{
        return [["name" : "Afghan", "code" : "afghani"],
                ["name" : "African", "code" : "african"],
                ["name" : "Indian", "code" : "indian"],
                ["name" : "American", "code" : "american"],
                ["name" : "Vietnamese", "code" : "vietnamese"],
                ["name" : "Malaysian", "code" : "malasyian"],
                ["name" : "korean", "code" : "korean"],
                ["name" : "Japanese", "code" : "japanese"],
                ["name" : "Chinese", "code" : "chinese"],
                ["name" : "Australian", "code" : "australian"]]
    }
    
    
}
