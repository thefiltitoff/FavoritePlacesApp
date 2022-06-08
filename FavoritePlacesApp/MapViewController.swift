//
//  MapViewController.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/8/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var place: Place!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlaceMark()
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    private func setupPlaceMark() {
        guard let location = place.location else { return }
        
         let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placeMarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placeMarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
}
