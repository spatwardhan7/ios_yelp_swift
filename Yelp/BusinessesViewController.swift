//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UIScrollViewDelegate, UISearchBarDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    @IBOutlet weak var tableView: UITableView!
    var isMoreDataLoading = false
    let searchBar = UISearchBar()
    var shouldShowSearchResults = false
    var filter = Filter()
    var yelpCategories : [[String:String]]!
    var yelpDistances : [Int : Double]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        yelpCategories = DataHelper.initYelpCategories()
        yelpDistances = DataHelper.initDistanceMapper()
        createSearchBar()
        
        // Call Yelp Search API
        networkCall()
        
    }
    
    func createSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredBusinesses = businesses?.filter({(business: Business) -> Bool in
            let businessName = business.name
            return businessName!.lowercased().range(of: searchText.lowercased()) != nil
            
        })
        
        if searchText != ""{
            shouldShowSearchResults = true
            tableView.reloadData()
        } else {
            shouldShowSearchResults = false
            tableView.reloadData()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            if shouldShowSearchResults{
                return (filteredBusinesses?.count)!
            }
            else {
                return businesses.count
            }
            
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        if shouldShowSearchResults {
            cell.business = filteredBusinesses?[indexPath.row]
        } else {
            cell.business = businesses[indexPath.row]
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // ... Code to load more results ...
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filter: Filter) {
        
        self.filter = filter.copy() as! Filter
        networkCall()
    }
    
    private func networkCall(){
        let categories = getCategoriesArray()
        var yelpSortMode : YelpSortMode
        
        switch self.filter.sortMode {
        case 0:
            yelpSortMode = YelpSortMode.bestMatched
        case 1 :
            yelpSortMode = YelpSortMode.distance
        case 2:
            yelpSortMode = YelpSortMode.highestRated
        default:
            yelpSortMode = YelpSortMode.bestMatched
        }
        
        let distanceInMeters = getDistanceInMeters()
        Business.searchWithTerm(term: "",distance : distanceInMeters ,sort: yelpSortMode, categories: categories, deals: self.filter.isDealsChecked) { (businesses : [Business]?,error :  Error?) in
            self.businesses = businesses
            self.tableView.reloadData()
            
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
        }
    }
    
    private func getDistanceInMeters() -> Double {
        let distanceInMiles = yelpDistances[self.filter.distance]!
        return distanceInMiles * 1609.34
    }
    
    private func getCategoriesArray() -> [String] {
        var selectedCategories = [String]()
        for (row,isSelected) in self.filter.cuisineStates {
            if isSelected{
                selectedCategories.append(yelpCategories[row]["code"]!)
                print("Selected Category: \(yelpCategories[row]["code"]!)")
            }
        }
        
        return selectedCategories
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.currentFilter = filter
        filtersViewController.delegate = self
    }
    
}
