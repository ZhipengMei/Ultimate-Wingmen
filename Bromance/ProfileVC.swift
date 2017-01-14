//
//  ProfileVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/26/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FBSDKCoreKit

class ProfileVC: UIViewController {

    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var username: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2  //circular image
        self.profilePic.clipsToBounds = true
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            //download image from facebook only when profile image does not exist
            if(self.profilePic.image == nil) {

                observeHelper.loadUserProfileUsingCache(thisUid: currentUser.uid) { (userprofile, error) in
                    if error != nil {
                        print("observeHelper error: \(error!)")
                    } else {
                        self.username.text = userprofile?.username   //display username
                        // do something with the userprofile
                        if let profileUrl = userprofile?.profile_pic_small {
                            self.profilePic.loadImageUsingCache(urlString: profileUrl)
                        }
                    }
                }//end observeHelper

            }//end  if image ==nil
        }//end if let current user
    }//end view did load

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //                //*** getting picture from facebook ***
    //                let fbprofileImage = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300,"width":300,"redirect":false], httpMethod:"GET")
    //                fbprofileImage?.start(completionHandler: {(connection, result, error) -> Void in
    //
    //                    print(result!)
    //                    print(connection!)
    //
    //                    if(error == nil) {
    //                        let dictionary = result as? NSDictionary        //store JSON result as a dictionary
    //                        let data = dictionary?.object(forKey: "data") //go inside the data node
    //                        let urlPic = ((data as AnyObject).object(forKey:"url"))! as! String//get the image url
    //
    //                        if let imageData = NSData(contentsOf: NSURL(string: urlPic)! as URL){
    //                            profileRef.put(imageData as Data, metadata: nil){  //upload profile image into firebase
    //                                metadata,error in
    //                                if(error == nil) {
    //                                    //size, content type or the download url
    //                                    //let downloadUrl = metadata!.downloadURL
    //                                } else {
    //                                    print("Error in downloading image")
    //                                }
    //                            }
    //                            //check cache, else download
    //                            self.profilePic.loadImageUsingCache(urlString: urlPic)
    //                        }//end if
    //                    }//end if
    //                })// *** getting picture from facebook end ***
    //                
    //            } //end if
    //        
    //        } else {
    //            
    //        }
    
    
    
    //download image from firebase storage example
    //            // Download from firebase storage in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    //            profileRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
    //                if error != nil {
    //                    print("Unable to download image")
    //                } else {
    //                    if(data != nil){
    //                        self.profilePic.image = UIImage(data:data!)
    //                    }
    //                }
    //            }
    

    
    //upload to firebase storage example
    //        //download image from facebook only when profile image does not exist
    //        if(self.profilePic.image == nil) {
    //            print("profile image is nil inside prifile VC")
    //            //*** getting picture from facebook ***
    //            let fbprofileImage = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300,"width":300,"redirect":false], httpMethod:"GET")
    //            fbprofileImage?.start(completionHandler: {(connection, result, error) -> Void in
    //
    //                print(result!)
    //                print(connection!)
    //
    //                if(error == nil) {
    //                    let dictionary = result as? NSDictionary        //store JSON result as a dictionary
    //                    let data = dictionary?.object(forKey: "data") //go inside the data node
    //                    let urlPic = ((data as AnyObject).object(forKey:"url"))! as! String//get the image url
    //
    //                    if let imageData = NSData(contentsOf: NSURL(string: urlPic)! as URL){
    //                        profileRef.put(imageData as Data, metadata: nil){  //upload profile image into firebase
    //                            metadata,error in
    //                            if(error == nil) {
    //                                //size, content type or the download url
    //                                //let downloadUrl = metadata!.downloadURL
    //                            } else {
    //                                print("Error in downloading image")
    //                            }
    //                        }
    //                        //check cache, else download
    //                        self.profilePic.loadImageUsingCache(urlString: urlPic)
    //                    }//end if
    //                }//end if
    //            })// *** getting picture from facebook end ***
    //            
    //        } //end if

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
