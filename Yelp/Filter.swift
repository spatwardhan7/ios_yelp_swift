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
    
    init(isDealsChecked: Bool = false, cuisineStates: [Int:Bool] = [Int:Bool]() ){
        self.isDealsChecked = isDealsChecked
        self.cuisineStates = cuisineStates
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Filter(isDealsChecked: isDealsChecked, cuisineStates: cuisineStates)
        return copy
    }
    
}
