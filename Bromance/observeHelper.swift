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
        
//        var userprofile: User?    //reset the variable
            //check if the profile already exist
//            if let index = userProfileCache.index(forKey: thisUid) {
////                print("using cache profile")
//                userprofile = userProfileCache[index].value
//                completion(userprofile!, nil)
//            } else {
                let ref = FIRDatabase.database().reference().child("user_profile").child(thisUid)

                //obserview once then stop receiving users update
//                ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let snapDict = snapshot.value as? NSDictionary{
//                        let thisUser = User(dict: snapDict as! [String : NSObject])
//                        userProfileCache[thisUid] = thisUser
//                        userprofile = userProfileCache[thisUid]
//                        completion(userprofile!, nil)
//                    }
//                }, withCancel: nil)
                
                //keep observing
                ref.observe(.value, with: { (snapshot) in
                    if let snapDict = snapshot.value as? NSDictionary{
                        let thisUser = User(dict: snapDict as! [String : NSObject])
                        
//                        //find the older element
//                        if let cacheIndex = userProfileCache.index(forKey: thisUid) {
//                            userProfileCache.remove(at: cacheIndex) //delete it
//                        }
                        //add the new one
//                        userProfileCache[thisUid] = thisUser
//                        userprofile = userProfileCache[thisUid]
//                        completion(userprofile!, nil)
                        completion(thisUser, nil)
                    }
                }, withCancel: nil)
                
//            }//end else
    }


}
