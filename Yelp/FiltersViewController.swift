//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc  protocol FiltersViewControllerDelegate{
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filter: Filter)
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , SwitchCellDelegate{
    
    let SECTION_DEALS = 0
    let SECTION_DISTANCE = 1
    let SECTION_SORT = 2
    let SECTION_CUISINES = 3
    
    // TODO: Update this as we go along adding more sections
    let NUM_SECTIONS = 4
    
    let DEALS_HEADER_TEXT = "Looking for Deals?"
    let DISTANCE_HEADER_TEXT = "Distance"
    let CUISINE_HEADER_TEXT = "Category"
    let SORT_HEADER_TEXT = "Sort by"
    
    let DEALS_LABEL_TEXT = "Deals"
    let DISTANCE_LABEL_TEXT = ["Auto", "0.3 miles", "1 mile", "5 miles", "20 miles"]
    let SORT_LABEL_TEXT = ["Best Matched", "Distance", "Highest Rated"]
    
    var isDistanceOpened : Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    var currentFilter: Filter!
    var tempFilter: Filter!
    
    var categories : [[String:String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = DataHelper.initYelpCategories()
        tableView.delegate = self
        tableView.dataSource = self
        
        //tempFilter = currentFilter
        tempFilter = currentFilter.copy() as! Filter
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSearchButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
        delegate?.filtersViewController!(filtersViewController: self, didUpdateFilters: tempFilter)
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_DEALS:
            return 1
        case SECTION_DISTANCE:
            if(isDistanceOpened){
                return DISTANCE_LABEL_TEXT.count
            } else {
                return 1
            }
        case SECTION_SORT:
            return SORT_LABEL_TEXT.count
        case SECTION_CUISINES:
            return categories.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case SECTION_DEALS :
            return DEALS_HEADER_TEXT
        case SECTION_DISTANCE:
            return DISTANCE_HEADER_TEXT
        case SECTION_SORT:
            return SORT_HEADER_TEXT
        case SECTION_CUISINES:
            return CUISINE_HEADER_TEXT
        default:
            return "Header section not found"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        cell.delegate = self
        
        switch indexPath.section {
        case SECTION_DEALS:
            cell.onSwitch.isHidden = false
            cell.radioButton.isHidden = true
            
            cell.switchLabel.text = DEALS_LABEL_TEXT
            cell.onSwitch.isOn = tempFilter.isDealsChecked
        case SECTION_DISTANCE:
            if(isDistanceOpened){
                cell.switchLabel.text = DISTANCE_LABEL_TEXT[indexPath.row]
                if(indexPath.row == tempFilter.distance){
                    cell.radioButton.isSelected = true
                }else {
                    cell.radioButton.isSelected = false
                }
            } else {
                cell.switchLabel.text = DISTANCE_LABEL_TEXT[tempFilter.distance]
                cell.radioButton.isSelected = true
            }

            cell.onSwitch.isHidden = true
            cell.radioButton.isHidden = false
        case SECTION_SORT:
            cell.switchLabel.text = SORT_LABEL_TEXT[indexPath.row]
            
            if(indexPath.row == tempFilter.sortMode){
                cell.radioButton.isSelected = true
            }else {
                cell.radioButton.isSelected = false
            }
            
            cell.onSwitch.isHidden = true
            cell.radioButton.isHidden = false
            break
        case SECTION_CUISINES:
            cell.onSwitch.isHidden = false
            cell.radioButton.isHidden = true
            cell.switchLabel.text = categories[indexPath.row]["name"]
            
            if tempFilter.cuisineStates[indexPath.row] != nil {
                cell.onSwitch.isOn = tempFilter.cuisineStates[indexPath.row]!
            } else {
                cell.onSwitch.isOn = false
            }
        default: break
            
        }
        return cell
    }
    
    func handleViews(didSelectRowAt indexPath: IndexPath){
        switch indexPath.section {
        case SECTION_DISTANCE:
            
            if(isDistanceOpened){
                let oldDistanceSelection = tempFilter.distance
                tempFilter.distance = indexPath.row
                if oldDistanceSelection != indexPath.row {
                    let oldSelectionIndexPath = NSIndexPath(row: oldDistanceSelection, section: indexPath.section)
                    self.tableView.reloadRows(at: [indexPath, oldSelectionIndexPath as IndexPath], with: .automatic)
                }
            }
            
            let opened = isDistanceOpened
            isDistanceOpened = !opened
            
            if opened {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.tableView.reloadSections(NSMutableIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
                }
            } else {
                self.tableView.reloadSections(NSMutableIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
            }
            
        default:
            break
        }
    }
    
    func switchCell(switchcell: SwitchCell, didChangeValue value: Bool) {
        print("filters view controller got the switch event")
        let indexPath = tableView.indexPath(for: switchcell)
        
        switch indexPath?.section {
        case SECTION_DEALS?:
            tempFilter.isDealsChecked = value
        case SECTION_DISTANCE?:
            handleViews(didSelectRowAt: indexPath!)
        case SECTION_SORT?:
            tempFilter.sortMode = (indexPath?.row)!
            print("Setting tempFilter.sortMode : \(tempFilter.sortMode)")
            self.tableView.reloadData()
        case SECTION_CUISINES?:
            tempFilter.cuisineStates[(indexPath?.row)!] = value
        default:
            break
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NUM_SECTIONS
    }
}
