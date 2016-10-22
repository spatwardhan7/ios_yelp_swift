//
//  DetailsViewController.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingsImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dealsImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var business : Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(business.coordinate != nil){
            let span = MKCoordinateSpanMake(0.075, 0.075)
            let coordinateRegion  = MKCoordinateRegionMake( business.coordinate, span)
            mapView.addAnnotation(business)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        
        nameLabel.text = business.name
        categoryLabel.text = business.categories
        addressLabel.text = business.address
        ratingsLabel.text = "\(business.reviewCount!) Reviews"
        distanceLabel.text = business.distance
        ratingsImageView.setImageWith(business.ratingImageURL!)
        phoneLabel.text = business.phone
        urlLabel.text = business.mobileURL?.components(separatedBy: "?")[0]
        
        if(business.deals != nil){
            dealsImageView.isHidden = false
        }
        
        if business.imageURL != nil {
            let imageUrlRequest = URLRequest(url: business.imageURL!)
            
            thumbImageView.setImageWith(imageUrlRequest, placeholderImage: nil,
                                        success: { (request : URLRequest, response : HTTPURLResponse?, image : UIImage!) in
                                            if image != nil {
                                                self.thumbImageView.alpha = 0
                                                self.thumbImageView.image = image
                                                UIView.animate(withDuration: 0.5 , animations: {() -> Void in
                                                    self.thumbImageView.alpha = 1
                                                })
                                            }
                                            
                }, failure: { (request : URLRequest,response : HTTPURLResponse?,error : Error) -> Void in
                    self.thumbImageView.image = #imageLiteral(resourceName: "no-image-found")
            })
        } else {
            self.thumbImageView.image = #imageLiteral(resourceName: "no-image-found")
        }
        
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
