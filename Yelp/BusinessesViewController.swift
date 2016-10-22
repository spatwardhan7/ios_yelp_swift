//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UIScrollViewDelegate, UISearchBarDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    @IBOutlet weak var tableView: UITableView!
    var loadingMoreView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    let searchBar = UISearchBar()
    var filter = Filter()
    var searchTerm = ""
    var yelpCategories : [[String:String]]!
    var yelpDistances : [Int : Double]!
    static var offset = 0
    var pullToRefresh : Bool = false
    let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        initInfiniteScrollIndicator()
        
        initRefreshControl()
        
        yelpCategories = DataHelper.initYelpCategories()
        yelpDistances = DataHelper.initDistanceMapper()
        createSearchBar()
        
        // Call Yelp Search API
        networkCall()
    }
    
    func initRefreshControl(){
        //refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        refreshControl.addTarget(self, action: #selector(self.refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        pullToRefresh = true
        networkCall()
    }
    
    func initInfiniteScrollIndicator(){
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(origin : CGPoint ( x : 0, y : tableView.contentSize.height),size : CGSize (width : tableView.bounds.size.width,height : InfiniteScrollActivityView.defaultHeight))
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    func createSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if ((searchBar.text) != nil) {
            BusinessesViewController.offset = 0
            searchTerm = searchBar.text!
            networkCall()
        }
        searchBar.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        
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
                BusinessesViewController.offset += 20
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(origin : CGPoint(x : 0, y : tableView.contentSize.height), size : CGSize (width : tableView.bounds.size.width, height : InfiniteScrollActivityView.defaultHeight))
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                networkCall()
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
        BusinessesViewController.offset = 0
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
        
        let localOffset = BusinessesViewController.offset
        
        if(pullToRefresh){
            // empty
        } else if(localOffset == 0 ){
            self.tableView.alpha = 0
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        let distanceInMeters = getDistanceInMeters()
        Business.searchWithTerm(term: searchTerm,distance : distanceInMeters ,sort: yelpSortMode, categories: categories, offset : localOffset ,deals: self.filter.isDealsChecked) { (businesses : [Business]?,error :  Error?) in
            
            if self.isMoreDataLoading{
                self.isMoreDataLoading = false
                self.loadingMoreView?.stopAnimating()
                self.businesses.append(contentsOf: businesses!)
                // TODO : dont reload entire table but only new rows
                self.tableView.reloadData()
            } else {
                self.businesses = businesses
                self.tableView.reloadData()
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated:true)
            }
            
            if(self.pullToRefresh){
                self.pullToRefresh = false
                self.refreshControl.endRefreshing()
            }
            
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.alpha = 1
            
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
        if (segue.identifier == "filterSegue"){
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            
            filtersViewController.currentFilter = filter
            filtersViewController.delegate = self
        } else if (segue.identifier == "mapSegue"){
            print("Map Segue")
        }
    }
    
    
}
