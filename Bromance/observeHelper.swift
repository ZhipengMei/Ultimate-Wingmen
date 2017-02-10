//
//  observeHelper.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/12/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import Firebase

//var userProfileCache = [String: User]()

class observeHelper {
    
    static func loadUserProfileUsingCache(thisUid: String, completion: @escaping (User?, Error?) -> Void) {
        
        let ref = FIRDatabase.database().reference().child("user_profile").child(thisUid)
        
        //keep observing
        ref.observe(.value, with: { (snapshot) in
            if let snapDict = snapshot.value as? NSDictionary{
                
                if snapDict["profile_pic_small"] == nil {
                    print("This user do not have profile image")
                    //checking profile image
                    let existingImageRef = FIRDatabase.database().reference().child("user_profile").child(thisUid).child("profile_pic_small")
                    //set default image
                    existingImageRef.setValue("https://firebasestorage.googleapis.com/v0/b/bromance-e91d8.appspot.com/o/default_image%2Fprofile_pic_small.jpg?alt=media&token=d18e1e96-08b3-4eb7-81e3-9a0f73d904c9")

//                    existingImageRef.observeSingleEvent(of: .value, with: {
//                        imageStuff in
//                        
//                        if let imageString = imageStuff.value as? String {
//                            print("ProfileVC: This user has a image.\n")
//                        } else {
//                            print("This user does not have a image.\n Creating a default image for this user.")
//                            //set up default image
//                            existingImageRef.setValue("https://firebasestorage.googleapis.com/v0/b/bromance-e91d8.appspot.com/o/default_image%2Fprofile_pic_small.jpg?alt=media&token=d18e1e96-08b3-4eb7-81e3-9a0f73d904c9")
//                        }
//                        
//                    })//end observe existingImageRef
                } else {
                    let thisUser = User(dict: snapDict as! [String : NSObject])
                    completion(thisUser, nil)
                }
                

            }
        }, withCancel: nil)
        
    }//end loadUserProfileUsingCache

}
