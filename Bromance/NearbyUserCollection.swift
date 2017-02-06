//
//  NearbyUserCollection.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/3/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation
import FirebaseDatabase
import GeoFire
import SVProgressHUD

private let reuseIdentifier = "CollectionViewCell"

class NearbyUserCollection: UICollectionViewController, CLLocationManagerDelegate {
    
    let user = FIRAuth.auth()?.currentUser                  //getting current user
    let rootRef = FIRDatabase.database().reference()    //reference to firebase database
    var nearbyUIDSet = Set<String>()               //google map refresh many times, using set to get non-duplicated data
    var nearbyUIDArray = [String]()
    let locationManager = CLLocationManager()                   // Create a location manager object
    var geoFire: GeoFire? = nil                         //geo instance for upload and retrieve location data to firebase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
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
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NearbyUsersCollectionCell

        // Configure the cell
        if((nearbyUIDArray.count) > 0){
            let uidAtIndex = self.nearbyUIDArray[indexPath.row]
            cell.profile = uidAtIndex
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if((nearbyUIDArray.count) > 0){
            let uidAtIndex = self.nearbyUIDArray[indexPath.row]
            
            //function to download user profile or use existing
            observeHelper.loadUserProfileUsingCache(thisUid: uidAtIndex) { (userprofile, error) in
                if error != nil {
                    print("observeHelper error: \(error!)")
                } else {
                    
                    if let profile = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as? ProfileVC {
                        
                        self.tabBarController?.tabBar.isHidden = true
                        profile.userID = uidAtIndex
                        
                        if let navigator = self.navigationController {
                            navigator.pushViewController(profile, animated: true)
                        }
                    }
                    
                }
            }//end observeHelper
        }//end if
    
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items

        if((nearbyUIDArray.count) != 0){            //making sure set is not empty
            self.collectionView?.backgroundView = nil
            SVProgressHUD.dismiss()
            return self.nearbyUIDArray.count
        } else {
            let frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            let emptyLabel = UILabel(frame: frame)
            emptyLabel.text = "No nearby user found"
            emptyLabel.textAlignment = NSTextAlignment.center
            self.collectionView?.backgroundView = emptyLabel
            SVProgressHUD.dismiss()
            return 0
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    //******Get current location******
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //setup user's current latitude and longitude
        let locationLat = (locationManager.location?.coordinate.latitude)!
        let locationLong = (locationManager.location?.coordinate.longitude)!
        //save location data to firebase
        saveGeoData(latitude: locationLat, longitude: locationLong)
        self.getNearbyUser() //get nearby users
        
        //display map view
        //        showCurrentLocationOnMap(lat: locationLat, long: locationLong)
        self.locationManager.stopUpdatingLocation() //stop updating location
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Stop significant-change location updates when they aren't needed anymore
        self.locationManager.stopMonitoringSignificantLocationChanges()
        
    }
    
    //function for saving GeoLocation data to firebase
    func saveGeoData(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        //create a GeoFire instance
        geoFire = GeoFire(firebaseRef: rootRef.child("locations") )    //create a child folder to store geo-location data
        let userID = user?.uid  //get user id
        //storing data to firebaseDatabase with key as uid
        geoFire?.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: userID)
    }
    
    func getNearbyUser(){
        self.nearbyUIDSet.removeAll()   //reset it
        // Query locations at user current location with a radius of 20 miles (math: 32186 meters /1000)
        let circleQuery = geoFire?.query(at: locationManager.location, withRadius: 32)
        //request for nearby user data
        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            //only get nearby location other than current user (compare by latitude, add compare longitude for more precise comparison)
            if (key != self.user?.uid){
                self.nearbyUIDSet.insert(key!)     //insert specific nearby user's uid query data into set (non-duplicated data)
            }
        })
        
        // call .observeReady block when .observe is finished
        circleQuery?.observeReady({
            //print("All initial data has been loaded and events have been fired!")
            if(self.nearbyUIDSet.count > 0){
                self.nearbyUIDArray = Array(self.nearbyUIDSet)  //convert set to array (contains a list of nearby users' uid)
                print("people nearby")
                print(self.nearbyUIDArray.count)
                self.collectionView?.reloadData()
            }
        })
    }

    


} //end class
