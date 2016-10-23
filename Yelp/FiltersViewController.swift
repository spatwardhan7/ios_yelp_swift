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
    var isSortOpened : Bool = false
    var isCuisineOpened : Bool = false
    var visibleCuisines = 3
    var totalCuisines : Int = DataHelper.initYelpCategories().count
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    var currentFilter: Filter!
    var tempFilter: Filter!
    
    var categories : [[String:String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor =  UIColor(red: (211/255.0), green: (35/255.0), blue: (35/255.0), alpha: 1.0)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        
        
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
            if(isSortOpened){
                return SORT_LABEL_TEXT.count
            } else {
                return 1
            }
        case SECTION_CUISINES:
            if(isCuisineOpened){
                return categories.count
            }
//            else {
//                if(visibleCuisines > 0 && visibleCuisines < totalCuisines){
//                    return visibleCuisines + 1 // + 1 for "See All" row
//                }
        
                return visibleCuisines + 1
            
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
        cell.textLabel?.text = ""
        cell.switchLabel.text = ""
        cell.accessoryType = UITableViewCellAccessoryType.none
        switch indexPath.section {
        case SECTION_DEALS:
              cell.switchLabel.text = DEALS_LABEL_TEXT
              if(tempFilter.isDealsChecked){
                cell.accessoryView = UIImageView(image : UIImage(named : "check-mark-5-16"))
              }else {
                cell.accessoryView = UIImageView(image : UIImage(named : "empty-circle-2-16"))
              }
        case SECTION_DISTANCE:
            if(isDistanceOpened){
                cell.switchLabel.text = DISTANCE_LABEL_TEXT[indexPath.row]
                if(indexPath.row == tempFilter.distance){
                    cell.accessoryView = UIImageView(image : UIImage(named : "check-mark-5-16"))
                }else {
                    cell.accessoryView = UIImageView(image : UIImage(named : "empty-circle-2-16"))
                }
            } else {
                cell.switchLabel.text = DISTANCE_LABEL_TEXT[tempFilter.distance]
                cell.accessoryView = UIImageView(image : UIImage(named : "arrow-27-16"))
            }
        case SECTION_SORT:
            if(isSortOpened){
                cell.switchLabel.text = SORT_LABEL_TEXT[indexPath.row]
                if(indexPath.row == tempFilter.sortMode){
                    cell.accessoryView = UIImageView(image : UIImage(named : "check-mark-5-16"))
                }else {
                    cell.accessoryView = UIImageView(image : UIImage(named : "empty-circle-2-16"))
                }
            } else {
                cell.switchLabel.text = SORT_LABEL_TEXT[tempFilter.sortMode]
                cell.accessoryView = UIImageView(image : UIImage(named : "arrow-27-16"))
            }
            break
        case SECTION_CUISINES:
            if(isCuisineOpened || indexPath.row < visibleCuisines){
                cell.textLabel?.text = ""
                cell.textLabel?.textAlignment = NSTextAlignment.left
                
                cell.switchLabel.text = categories[indexPath.row]["name"]
                if tempFilter.cuisineStates[indexPath.row] != nil {
                    //print("cellForRowAt - cuisine state not nil")
                    let switchState : Bool = tempFilter.cuisineStates[indexPath.row]!
                    //print("cellForRowAt -- cuisine state is : \(switchState)")
                    if(switchState == true){
                        cell.accessoryView = UIImageView(image : UIImage(named : "check-mark-5-16"))
                    }else {
                        cell.accessoryView = UIImageView(image : UIImage(named : "empty-circle-2-16"))
                    }
                } else {
                    //print("cellForRowAt - cuisine state nil at index : \(indexPath.row) , setting empty image and name: \(categories[indexPath.row]["name"])")
                    cell.accessoryView = UIImageView(image : UIImage(named : "empty-circle-2-16"))
                }
            
            } else {
                //print("cellForRowAt - See All printed at index: \(indexPath.row)")
                if(cell.accessoryView != nil) {
                    cell.accessoryView = nil
                }
                cell.textLabel?.text = "See All"
                cell.textLabel?.textAlignment = NSTextAlignment.center
            }
            break
        default: break
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case SECTION_DEALS:
            handleViews(didSelectRowAt: indexPath)
        case SECTION_DISTANCE:
            handleViews(didSelectRowAt: indexPath)
        case SECTION_SORT:
            handleViews(didSelectRowAt: indexPath)
        case SECTION_CUISINES:
            handleViews(didSelectRowAt: indexPath)
        default: break
        }
    }
    
    func handleViews(didSelectRowAt indexPath: IndexPath){
        switch indexPath.section {
        case SECTION_DEALS:
            let oldSelection : Bool = tempFilter.isDealsChecked
            tempFilter.isDealsChecked = !oldSelection
            self.tableView.reloadData()
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
            
        case SECTION_SORT:
            
            if(isSortOpened){
                let oldSortSelection = tempFilter.sortMode
                tempFilter.sortMode = indexPath.row
                if oldSortSelection != indexPath.row {
                    let oldSelectionIndexPath = NSIndexPath(row: oldSortSelection, section: indexPath.section)
                    self.tableView.reloadRows(at: [indexPath, oldSelectionIndexPath as IndexPath], with: .automatic)
                }
            }
            
            let opened = isSortOpened
            isSortOpened = !opened
            
            if opened {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.tableView.reloadSections(NSMutableIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
                }
            } else {
                self.tableView.reloadSections(NSMutableIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
            }
        
        case SECTION_CUISINES:
            if(!isCuisineOpened && indexPath.row == visibleCuisines){
                //print("handleViews --- cuisine was not open. clicked on see all")
                isCuisineOpened = true
                self.tableView.reloadSections(NSMutableIndexSet(index: indexPath.section) as IndexSet, with: .automatic)
                
            } else {
                //print("handleViews ---- cuisine was open.")
                if(tempFilter.cuisineStates[(indexPath.row)] != nil ){
                    //print("handleViews ----- cuisine state not nil")
                    let oldState : Bool = tempFilter.cuisineStates[(indexPath.row)]!
                    //print("handleViews ------ cuisine state value : \(oldState) ")
                    tempFilter.cuisineStates[(indexPath.row)] = !oldState
                    //print("handleViews ------- cuisine state value now set to: \(tempFilter.cuisineStates[(indexPath.row)]!) ")
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }else {
                    //print("handleViews ----- cuisine state nil")
                    tempFilter.cuisineStates[(indexPath.row)] = true
                    //print("handleViews ------- cuisine state value now set to: \(tempFilter.cuisineStates[(indexPath.row)]!) ")
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
            
        default:
            break
        }
    }
    
//    func switchCell(switchcell: SwitchCell, didChangeValue value: Bool) {
//        print("filters view controller got the switch event")
//        let indexPath = tableView.indexPath(for: switchcell)
//        
//        switch indexPath?.section {
//        case SECTION_DEALS?:
//            tempFilter.isDealsChecked = value
//        case SECTION_DISTANCE?:
//            //handleViews(didSelectRowAt: indexPath!, didChangeValue: value)
//        case SECTION_SORT?:
//            //handleViews(didSelectRowAt: indexPath!, didChangeValue: value)
//        case SECTION_CUISINES?:
//            //tempFilter.cuisineStates[(indexPath?.row)!] = value
//            //handleViews(didSelectRowAt: indexPath!, didChangeValue: value)
//        default:
//            break
//        }
//        
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NUM_SECTIONS
    }
}
