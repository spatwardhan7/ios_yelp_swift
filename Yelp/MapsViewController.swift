//
//  MapsViewController.swift
//  Yelp
//
//  Created by Patwardhan, Saurabh on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MapsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var businesses: [Business]!
    var filter : Filter!
    var searchTerm = ""
    
    
    let regionRadius: CLLocationDistance = 500
    let initialLocation = CLLocation(latitude: 37.785771, longitude: -122.406165)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if(businesses != nil && filter != nil){
            print("Received businesses and filter from list view")
            addAnnotations(businesses: businesses)
            
        }
        
        centerMapOnLocation(location: initialLocation)
        // Do any additional setup after loading the view.
    }
    
    func addAnnotations(businesses : [Business]){
        mapView.addAnnotations(businesses)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        /*
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0,regionRadius * 2.0)
 */
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
