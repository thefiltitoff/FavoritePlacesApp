//
//  MapViewController.swift
//  FavoritePlacesApp
//
//  Created by Felix Titov on 6/8/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIndentifier = ""
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                and: previousLocation) { currentLocation in
                    self.previousLocation = currentLocation
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.mapManager.showUserLocation(mapView: self.mapView)
                    }
                }
        }
    }
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var routeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }
    
    private func setupMapView() {
        routeButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIndentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIndentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            routeButton.isHidden = false
        }
    }
    
    @IBAction func closeButtonPressed() {
        dismiss(animated: true)
    }
    
    @IBAction func centerViewByUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(address: addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func routeButtonPressed() {
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
    }
}

// MARK: Work with MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIndentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let city = placemark?.locality
            let streetName = placemark?.thoroughfare
            let numberBuild =  placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if city != nil && streetName != nil && numberBuild != nil {
                    self.addressLabel.text = "\(city!), \(streetName!), \(numberBuild!)"
                    
                } else if streetName != nil && numberBuild != nil {
                    self.addressLabel.text = "\(streetName!), \(numberBuild!)"
                    
                }  else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                    
                } else {
                    self.addressLabel.text = ""
                }
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.strokeColor = .blue
        
        return renderer
    }
}

// MARK: Work with CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuth(mapView: mapView,
                                     incomeSegueIndentifier: incomeSegueIndentifier)
    }
}

