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
        
        if let user = FIRAuth.auth()?.currentUser {
            //user is signed in
            let name = user.displayName
            
            self.username.text = name   //display username

            //reference to the storage
            let storage = FIRStorage.storage()
            let storageRef = storage.reference(forURL: "gs://bromance-e91d8.appspot.com")  //reference to your particular storage service
            let profileRef = storageRef.child(user.uid + "/profile_pic_small.jpg")            //create a child reference "profile_pic.jpg"

            //download image every time is a hassle
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
            
            let thisImageUrl = "\(user.photoURL!)"
            self.profilePic.loadImageUsingCache(urlString: thisImageUrl)
            
            //download image from facebook only when profile image does not exist
            if(self.profilePic.image == nil) {
                
                //*** getting picture from facebook ***
                let fbprofileImage = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300,"width":300,"redirect":false], httpMethod:"GET")
                fbprofileImage?.start(completionHandler: {(connection, result, error) -> Void in
                    
                    //print(result)
                    
                    if(error == nil) {
                        let dictionary = result as? NSDictionary        //store JSON result as a dictionary
                        let data = dictionary?.object(forKey: "data") //go inside the data node
                        let urlPic = ((data as AnyObject).object(forKey:"url"))! as! String//get the image url
                        
                        if let imageData = NSData(contentsOf: NSURL(string: urlPic)! as URL){
                            profileRef.put(imageData as Data, metadata: nil){  //upload profile image into firebase
                                metadata,error in
                                if(error == nil) {
                                    //size, content type or the download url
                                    //let downloadUrl = metadata!.downloadURL
                                } else {
                                    print("Error in downloading image")
                                }
                            }
                            //check cache, else download
                            self.profilePic.loadImageUsingCache(urlString: urlPic)
                        }//end if
                    }//end if
                })// *** getting picture from facebook end ***
                
            } //end if
        
        } else {
            
        }
         
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
