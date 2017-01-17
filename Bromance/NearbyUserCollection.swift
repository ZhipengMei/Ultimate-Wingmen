//
//  NearbyUserCollection.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/3/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "CollectionViewCell"

class NearbyUserCollection: UICollectionViewController {
    
    var usersArrayNearby = [String]()
    var loggedInUserNearby: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NearbyUsersCollectionCell

        // Configure the cell
        if(usersArrayNearby.count > 0){
            let uidAtIndex = self.usersArrayNearby[indexPath.row]
            cell.profile = uidAtIndex
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(usersArrayNearby.count > 0){
            let uidAtIndex = self.usersArrayNearby[indexPath.row]
            
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
        var count = 0
        if(usersArrayNearby.count > 0){            //making sure set is not empty
            count = self.usersArrayNearby.count
        }
        return count
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
    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
