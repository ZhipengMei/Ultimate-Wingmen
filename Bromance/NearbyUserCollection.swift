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

    var usersArrayNearby = [AnyObject]()
    var loggedInUserNearby: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var count = 0
        if(usersArrayNearby.count > 0){            //making sure set is not empty
            count = self.usersArrayNearby.count
        }
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NearbyUsersCollectionCell
    
        // Configure the cell
        if(usersArrayNearby.count > 0){
            //display username
            cell.usernameLabel.text = (self.usersArrayNearby[indexPath.row]["username"] as? String)!.components(separatedBy: " ")[0]

            //display user image (make sure image is avaialbe and permission to access)
            if let imageURL = self.usersArrayNearby[indexPath.row]["profile_pic_small"]  {
                //attempting to load image from cache, else download
                cell.userImage.loadImageUsingCache(urlString: imageURL as! String)
                //add a border to the images
                cell.userImage.layer.borderWidth = 1.5
            } else {
                //use default image
                let defaultImageURL = "https://firebasestorage.googleapis.com/v0/b/bromance-e91d8.appspot.com/o/default%2Fprofile_pic_small.jpg?alt=media&token=02d85d91-ac43-4a0b-a8f6-32b0821b51e4"
                
                //attempting to load image from cache, else download
                cell.userImage.loadImageUsingCache(urlString: defaultImageURL)
                //add a border to the images
                cell.userImage.layer.borderWidth = 1.5
                
            }//end else
            
            let connections = (self.usersArrayNearby[indexPath.row]).object(forKey: "connections") as! NSDictionary
            for(deviceID, connection) in connections {
                if((connection as! NSDictionary).object(forKey: "online") as! Bool)
                {
                    cell.userImage.layer.borderColor = UIColor.green.cgColor
                } else {
                    cell.userImage.layer.borderColor = UIColor.red.cgColor
                }
            }
            
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Create a variable that you want to send based on the destination view controller
        // You can get a reference to the data by using indexPath shown below
        let selectedPackage = self.usersArrayNearby[indexPath.row] as? NSDictionary
        let selectedPackageUsername = self.usersArrayNearby[indexPath.row]["username"] as? String
        let selectedReceiverId = selectedPackage?.object(forKey: "uID")
        
        // handle tap events
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
        chatVC.senderId = self.loggedInUserNearby?.uid
        chatVC.senderDisplayName = selectedPackageUsername
        chatVC.receiverId =  selectedReceiverId as! String!
        chatVC.receiverData =  selectedPackage as AnyObject!
        
        self.navigationController?.pushViewController(chatVC, animated: true)
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
