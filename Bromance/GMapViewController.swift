//
//  GMapViewController.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/15/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import GeoFire
import FirebaseDatabase
import Firebase
import FirebaseAuth


class GMapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var myView: UIView!                       //myView contains 2 subview (mapview and tableview)
    let deviceID = UIDevice.current.identifierForVendor?.uuidString //store the device id
    let user = FIRAuth.auth()?.currentUser                  //getting current user
    let rootRef = FIRDatabase.database().reference()    //reference to firebase database
    var mapView: GMSMapView?                            //display nearby users
    var nearbyUIDSet = Set<String>()               //google map refresh many times, using set to get non-duplicated data
    var nearbyUIDArray: [String]?
    let locationManager = CLLocationManager()                   // Create a location manager object
    var geoFire: GeoFire? = nil                         //geo instance for upload and retrieve location data to firebase
    
    var myActivityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView()
    
    //initialize coordinate instance, making sure app wont crash when location not turn on
//    var locationLat: CLLocationDegrees = 0
//    var locationLong: CLLocationDegrees = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //update user connections status
        let myConnectionsRef = rootRef.child("user_profile").child("\((user?.uid)!)").child("connections").child("\(self.deviceID!)")
        myConnectionsRef.child("online").setValue(true) //when user logged in, set value to true
        myConnectionsRef.child("last_online").setValue(NSDate().timeIntervalSince1970)
        
        
        //get current location
        // Ask for authorization from the User.
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()           // Request location authorization
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self         // Set the delegate
            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers //less accurate to save power
            self.locationManager.startUpdatingLocation()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        rootRef.removeAllObservers()
        self.mapView = nil
        self.mapView?.delegate = nil
    }
    
    //******Get current location******
//    func startSignificantChangeLocationUpdates() {
//        // Ask for authorization from the User.
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.requestAlwaysAuthorization()           // Request location authorization
//        
//        if CLLocationManager.locationServicesEnabled() {
//            self.locationManager.delegate = self         // Set the delegate
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers //less accurate to save power
//            self.locationManager.startUpdatingLocation()
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //setup user's current latitude and longitude
        let locationLat = (locationManager.location?.coordinate.latitude)!
        let locationLong = (locationManager.location?.coordinate.longitude)!

        showCurrentLocationOnMap(lat: locationLat, long: locationLong)
        self.locationManager.stopUpdatingLocation() //stop updating location
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.view.alpha = 1
        }) {(success: Bool) in
            self.myActivityIndicator.stopAnimating()
        }

    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Stop significant-change location updates when they aren't needed anymore
        self.locationManager.stopMonitoringSignificantLocationChanges()
        
    }
    
    //******Get current location End ******
    
    
    
    // *** google map view ***
    
    //disllaying the user's current location with marker
    func showCurrentLocationOnMap(lat: CLLocationDegrees, long: CLLocationDegrees){
        
        //saving location data onto firebase
        saveGeoData(latitude: lat, longitude: long)

        //getting current position to map
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 9.5)
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: self.myView.frame.size.width, height: self.myView.frame.size.height), camera: camera)
        
        //setting up transparent blue color for radius range
        let blue = UIColor.blue // 1.0 alpha
        let semi = blue.withAlphaComponent(0.5) // 0.5 alpha
        
        //adding circle to mapview
        let circle = GMSCircle()
        circle.radius = 32186 // 20 miles
        circle.fillColor = semi
        circle.position = (self.locationManager.location?.coordinate)! // Your CLLocationCoordinate2D  position
        circle.strokeWidth = 5;
        circle.strokeColor = UIColor.clear
        circle.map = mapView; // Add it to the map
        
        //add marker to map view
        let marker = GMSMarker()
        marker.position = camera.target     //place marker to current user position onto the map
        marker.snippet = "Current Location"
        marker.icon =  GMSMarker.markerImage(with: UIColor.green)  //set the marker to yellow color
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
        
        self.myView.addSubview(self.mapView!) //Add google map to superview
        getNearbyUser()
    }
    
    //function for saving GeoLocation data to firebase
    func saveGeoData(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        //create a GeoFire instance
        geoFire = GeoFire(firebaseRef: rootRef.child("locations") )    //create a child folder to store geo-location data
        let userID = user?.uid  //get user id
        //storing data to firebaseDatabase with key as uid
        geoFire?.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: userID)
    }
    
    // refresh buttion trigger grab new user's current location
    @IBAction func refresh(_ sender: Any) {
        self.view.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 0.5
            self.animateActivityIndicator()
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }        
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func getNearbyUser(){
        self.nearbyUIDSet.removeAll()   //reset it
        // Query locations at user current location with a radius of 20 miles (math: 32186 meters /1000)
        let circleQuery = geoFire?.query(at: locationManager.location, withRadius: 32)
        //request for nearby user data
        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            //only get nearby location other than current user (compare by latitude, add compare longitude for more precise comparison)
            if (key != self.user?.uid){
                //add nearby user's marker to map view
                let otherUserMarker = GMSMarker()
                otherUserMarker.position = (location?.coordinate)!     //place marker to current user position onto the map
                otherUserMarker.snippet = "Player In Action"
                otherUserMarker.appearAnimation = kGMSMarkerAnimationPop
                otherUserMarker.map = self.mapView
                self.nearbyUIDSet.insert(key!)     //insert specific nearby user's uid query data into set (non-duplicated data)
            }
        })
        
        // call .observeReady block when .observe is finished 
        circleQuery?.observeReady({
            //print("All initial data has been loaded and events have been fired!")
            if(self.nearbyUIDSet.count > 0){
                self.nearbyUIDArray = Array(self.nearbyUIDSet)  //convert set to array (contains a list of nearby users' uid)
            }
        })
    }
    // *** google map view end ***

    //checking/update users online status
//    func manageConnections(userID: String) {
//        //create a reference to the database
//        let myConnectionsRef = rootRef.child("user_profile").child("\(userID)").child("connections").child("\(self.deviceID!)")
//        //when user logged in, set value to true
//        myConnectionsRef.child("online").setValue(true)
//        myConnectionsRef.child("last_online").setValue(NSDate().timeIntervalSince1970)
//    }//manageConnections end

    //activity indicator
    func animateActivityIndicator() {
        self.myActivityIndicator.center = self.view.center
        self.myActivityIndicator.hidesWhenStopped = true
        self.myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.myActivityIndicator.color = UIColor.red
        self.view.alpha = 0.8
        self.view.addSubview(myActivityIndicator)
        myActivityIndicator.startAnimating()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if self.nearbyUIDArray != nil {
            if segue.identifier == "toCollection" {
                if let collectionVC = segue.destination as? NearbyUserCollection {
                    guard let loggedInUser = FIRAuth.auth()?.currentUser else { return }
                    collectionVC.usersArrayNearby = self.nearbyUIDArray!
                    collectionVC.loggedInUserNearby = loggedInUser
                }
            }
        }
    }//end prepare function
    
    
    
    
}


