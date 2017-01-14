//
//  NearbyUsersCollectionCell.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/28/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit

class NearbyUsersCollectionCell: UICollectionViewCell {
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    
    //overriding the user image to make it circular
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeItRound()
    }
    
    func makeItRound() {
        self.userImage.layer.masksToBounds = true
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2.0
    }
    
    //parse array of uid into readable user profile data
    var profile: String? {
        didSet {
            setupNameAndProfileImage(profileid: profile!)
        }
    }
    
    
    //get the chatpartner using the partner's id from message
    fileprivate func setupNameAndProfileImage(profileid: String) {
        
        //helper function to download user profile
        observeHelper.loadUserProfileUsingCache(thisUid: profileid) { (userprofile, error) in
            if error != nil {
                print("observeHelper error: \(error!)")
            } else {
                // do something with the userprofile
                self.usernameLabel.text = userprofile?.username?.components(separatedBy: " ")[0]
                self.userImage.loadImageUsingCache(urlString: (userprofile?.profile_pic_small)!)
                //add a border to the images
                self.userImage.layer.borderWidth = 1.5
                
                let connections = userprofile?.connections
                for(deviceID, connection) in connections! { //goes through each deviceID and set connections
                    if((connection as! NSDictionary).object(forKey: "online") as! Bool)
                    {
                        self.userImage.layer.borderColor = UIColor.green.cgColor    //display as online
                    } else {
                        self.userImage.layer.borderColor = UIColor.red.cgColor  //display as offline
                    }
                }
            }
        }//end observeHelper
    }//end fileprivate
    
}
