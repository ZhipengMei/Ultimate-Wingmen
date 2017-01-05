//
//  ProfileDetailViewController.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/26/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKCoreKit
import TwitterKit
import GoogleSignIn

class ProfileDetailViewController: UITableViewController {

    //store the device id
    let deviceID = UIDevice.current.identifierForVendor?.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onLogout(sender: AnyObject) {
        
        //update user online status
        let userID = FIRAuth.auth()?.currentUser?.uid
        let myConnectionsRef = FIRDatabase.database().reference(withPath: "user_profile/\(userID!)/connections/\(self.deviceID!)")
        myConnectionsRef.child("online").setValue(false)
        myConnectionsRef.child("last_online").setValue(NSDate().timeIntervalSince1970)

        
        //signs the user out of the Firebase app
        try! FIRAuth.auth()!.signOut()
        
        //sign the user out of the facebook app
        FBSDKAccessToken.setCurrent(nil)
        
        //sign the user out of the google app
        GIDSignIn.sharedInstance().signOut()

        
//        //sign the user out of the twitter
//        let client = TWTRAPIClient.withCurrentUser()
//        Twitter.sharedInstance().sessionStore.logOutUserID(client.userID!)


        
        
        print("User logged out successfully")

    }


}
