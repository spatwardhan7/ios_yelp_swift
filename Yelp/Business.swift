//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class Business: NSObject, MKAnnotation{
    let name: String?
    let address: String?
    let imageURL: URL?
    let categories: String?
    let distance: String?
    let ratingImageURL: URL?
    let reviewCount: NSNumber?
    let latitude : Double?
    let longitude : Double?
    var coordinate: CLLocationCoordinate2D
    var subtitle : String?
    var title : String?
    var deals : [AnyObject]?
    var phone : String?
    var mobileURL : String?
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = URL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        }
        self.address = address
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joined(separator: ", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = URL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
        
        let storeLocation = dictionary["location"] as? NSDictionary
        let coordinateDict = storeLocation?["coordinate"] as? NSDictionary
        
        let latLoc = coordinateDict?["latitude"] as? Double
        if latLoc != nil {
            latitude = latLoc!
        } else {
            latitude = nil
        }
        
        let longLoc = coordinateDict?["longitude"] as? Double?
        if longLoc != nil {
            longitude = longLoc!
        } else {
            longitude = nil
        }
        
        if let dealsObj = dictionary["deals"] as? [AnyObject] {
            deals = dealsObj
        } else {
            deals = nil
        }
        
        let displayPhoneString = dictionary["display_phone"] as? String
        if displayPhoneString != nil {
            phone = displayPhoneString
        } else {
            phone = nil
        }
        
        let mobileURLString = dictionary["url"] as? String
        if mobileURLString != nil {
            mobileURL = mobileURLString
        } else {
            mobileURL = nil
        }
        
        coordinate = CLLocationCoordinate2D()
        coordinate.latitude = latitude!
        coordinate.longitude = longitude!
        
        title = name
        subtitle = address
        
    }

    
    class func businesses(array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, completion: @escaping ([Business]?, Error?) -> Void) {
        _=YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func searchWithTerm(term: String,distance: Double? ,sort: YelpSortMode?, categories: [String]?, offset: Int?, deals: Bool?, completion: @escaping ([Business]?, Error?) -> Void) -> Void {
        _=YelpClient.sharedInstance.searchWithTerm(term, distance: distance, sort: sort, categories: categories, offset : offset ,deals: deals, completion: completion)
    }
}
