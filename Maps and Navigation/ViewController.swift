//
//  ViewController.swift
//  Maps and Navigation
//
//  Created by MD Salauddin on 23/7/18.
//  Copyright © 2018 Jorudan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}

class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var MapKitView: MKMapView!
    
    var locationManager = CLLocationManager()
    override func viewDidLoad(){
        super.viewDidLoad()

        MapKitView.delegate = self
        MapKitView.showsScale = true
        MapKitView.showsCompass = true
        MapKitView.showsTraffic = true
        MapKitView.showsBuildings = true
        MapKitView.showsPointsOfInterest = true
        MapKitView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        
                switch CLLocationManager.authorizationStatus(){
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager.startUpdatingLocation()
                case .restricted, .denied:
                    do{
                        let alertController = UIAlertController( title: "Location Access is OFF!", message: "You Can Allow Location Access for this app from Settings -> Privacy -> Location Services - > Maps", preferredStyle: UIAlertController.Style.alert )
                        alertController.addAction(UIAlertAction( title: "Dismiss", style: UIAlertAction.Style.default,handler: nil ))
                        self.present( alertController, animated: true, completion: nil )
                    }
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    // Showing current location on startup
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        self.MapKitView.setRegion(region, animated: true)

            //To stop continous updating the location
            manager.stopUpdatingLocation()
            manager.delegate = nil
        
            //Not Using Now!
//        let pointAnnotation = MKPointAnnotation()
//        pointAnnotation.coordinate = location!.coordinate
//        pointAnnotation.title = "This is You"
//        MapKitView.addAnnotation(pointAnnotation)
    }
    
    // Switch Map Type
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBAction func segmentaction(_ sender: UISegmentedControl){
        if segment.selectedSegmentIndex == 0{
            MapKitView.mapType = .standard
        }
        else if segment.selectedSegmentIndex == 1{
            MapKitView.mapType = .satellite
        }
        else if segment.selectedSegmentIndex == 2{
            MapKitView.mapType = .hybrid
        }

            //Not using now!
//        else if segment.selectedSegmentIndex == 3{
//            MapKitView.mapType = .mutedStandard
//
//        }
//        else if segment.selectedSegmentIndex == 4{
//            MapKitView.mapType = .satelliteFlyover
//
//        }
//        else if segment.selectedSegmentIndex == 5{
//            MapKitView.mapType = .hybridFlyover
//
//        }
        
    }

    // Fly to MyLocation
    @IBAction func zoomToCurrentLocation(_ sender: UIButton){
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
                let region = MKCoordinateRegion.init(center: (locationManager.location?.coordinate)!, span: span)
                MapKitView.setRegion(region, animated: true)

            case .notDetermined, .restricted, .denied:
                //Exception Handling
                do{
                    let alertController = UIAlertController ( title: "Location Access is OFF!", message: "Allow Location Access from Settings -> Privacy -> Location Services - > Maps -> While Using the App", preferredStyle: UIAlertController.Style.alert )
                    alertController.addAction( UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil ) )
                    self.present( alertController, animated: true, completion: nil )
                }
            }
        }
    }
    
    // Zoom In/Out
    @IBAction func ZoomIn(_ sender: UIButton){
        var region: MKCoordinateRegion = MapKitView.region
        region.span.latitudeDelta /= 1.50
        region.span.longitudeDelta /= 1.50
        MapKitView.setRegion( region, animated: true )
    }
    
    @IBAction func ZoomOut(_ sender: UIButton){
        var region: MKCoordinateRegion = MapKitView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 1.50, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 1.50, 180.0)
        MapKitView.setRegion( region, animated: true )
    }
    
   // Search Bar
    @IBAction func searchButton(_ sender: UIBarButtonItem){
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //Ignore user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity Indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        self.view.addSubview( activityIndicator )
        
        //Hide Searchbar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Search Request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { ( response, error ) in activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
            if response == nil{
                print ("ERROR, Search Again..")
            }
            else{
                //Remove annotations
                let annotations = self.MapKitView.annotations
                self.MapKitView.removeAnnotations( annotations )
                
                //Getting Data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //Create annotations
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake( latitude!, longitude! )
                self.MapKitView.addAnnotation( annotation )
                
                //Zooming in on annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake( latitude!, longitude! )
                let span = MKCoordinateSpan.init( latitudeDelta: 0.015, longitudeDelta: 0.015 )
                let region = MKCoordinateRegion.init( center: coordinate, span: span )
                self.MapKitView.setRegion( region, animated: true )
            }
        }
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
}
