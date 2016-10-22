//
//  MapsViewController.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD

class MapsViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var businesses: [Business]!
    var filter : Filter!
    var searchTerm = ""
    
    let regionRadius: CLLocationDistance = 500
    let initialLocation = CLLocation(latitude: 37.785771, longitude: -122.406165)

    let searchBar = UISearchBar()
    
    
    var yelpCategories = DataHelper.initYelpCategories()
    var yelpDistances = DataHelper.initDistanceMapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if(businesses != nil && filter != nil){
            print("Received businesses and filter from list view")
            addAnnotations(businesses: businesses)
            
        }
        createSearchBar()
        centerMapOnLocation(location: initialLocation)
        // Do any additional setup after loading the view.
    }
    
    func createSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.text = searchTerm
        self.navigationItem.titleView = searchBar
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if ((searchBar.text) != nil) {
            searchTerm = searchBar.text!
            networkCall()
        }
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func addAnnotations(businesses : [Business]){
        mapView.addAnnotations(businesses)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.075, 0.075)

        let coordinateRegion  = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation  = annotation as? Business {
            let identifier = "pin"
            
            var view : MKPinAnnotationView
            
            if let dequeView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            
                dequeView.annotation = annotation
                view = dequeView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type : UIButtonType.detailDisclosure) as UIView
            }
            return view
        }
        return nil
        
    }
    
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
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Business.searchWithTerm(term: searchTerm,distance : distanceInMeters ,sort: yelpSortMode, categories: categories, offset : nil ,deals: self.filter.isDealsChecked) { (businesses : [Business]?,error :  Error?) in
            
            self.mapView.removeAnnotations(self.businesses)
            
            self.businesses = businesses
            
            self.addAnnotations(businesses: self.businesses)
    
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                    print(business.latitude!)
                    print(business.longitude!)
                }
            }
        }
        MBProgressHUD.hide(for: self.view, animated: true)

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
    


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "filterFromMapSegue"){
            let navigationController = segue.destination as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            
            filtersViewController.currentFilter = filter
            filtersViewController.delegate = self
        }
    
        
    }

}
