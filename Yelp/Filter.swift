//
//  Filters.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class Filter: NSObject, NSCopying {
    
    var isDealsChecked: Bool = false
    var cuisineStates = [Int:Bool]()
    // Sort mode: 0=Best matched (default), 1=Distance, 2=Highest Rated.
    var sortMode : Int = 0
    var distance : Int = 0
    
    init(isDealsChecked: Bool = false, cuisineStates: [Int:Bool] = [Int:Bool](), sortMode: Int = 0 , distance : Int = 0){
        self.isDealsChecked = isDealsChecked
        self.cuisineStates = cuisineStates
        self.sortMode = sortMode
        self.distance = distance
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Filter(isDealsChecked: isDealsChecked, cuisineStates: cuisineStates, sortMode : sortMode, distance : distance)
        return copy
    }
    
}
