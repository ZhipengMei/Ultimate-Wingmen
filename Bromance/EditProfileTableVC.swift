//
//  EditProfileTableVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/27/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EditProfileTableVC: UITableViewController {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var emailAddress: UILabel!
    @IBOutlet var gender: UILabel!
    @IBOutlet var website: UILabel!
    @IBOutlet var yearsInGame: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var level: UILabel!
    
    var myActivityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView()
    
    var user = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //retrieving user basic info data from firebase
        //function to download user profile or use existing
        updateProfile(thisUid: (user?.uid)!) { (userprofile, error) in
            if error == nil {
                self.username.text = userprofile?.username
                self.emailAddress.text = userprofile?.email
                self.gender.text = userprofile?.gender
                self.website.text = userprofile?.website
                self.yearsInGame.text = userprofile?.years_in_game
                self.age.text = userprofile?.age
                self.profileImage.loadImageUsingCache(urlString: (userprofile?.profile_pic_small)!)
                self.level.text = userprofile?.level
            }//end if
        }//end observeHelper
        
        //following code can be use in emergency
//        let thisref = FIRDatabase.database().reference().child("user_profile").child((user?.uid)!)
//        //keep observing
//        thisref.observe(.value, with: { (snapshot) in
//            if let snapDict = snapshot.value as? NSDictionary{
//                self.username.text = snapDict["username"] as? String
//                self.emailAddress.text = snapDict["email"] as? String
//                self.gender.text = snapDict["gender"] as? String
//                self.website.text = snapDict["website"] as? String
//                self.yearsInGame.text = snapDict["years_in_game"] as? String
//                self.age.text = snapDict["age"] as? String
//                self.profileImage.loadImageUsingCache(urlString: (snapDict["profile_pic_small"])! as! String)
//                self.level.text = snapDict["level"] as? String
//            }
//        }, withCancel: nil)
//        
    }//end view did load
    
    //update the user profile and save it into cache
    var userprofile: User?    //reset the variable
    func updateProfile(thisUid: String, completion: @escaping (User?, Error?) -> Void) {
        let thisref = FIRDatabase.database().reference().child("user_profile").child((user?.uid)!)
        //keep observing
        thisref.observe(.value, with: { (snapshot) in
            if let snapDict = snapshot.value as? NSDictionary{
                let thisUser = User(dict: snapDict as! [String : NSObject])
                
                //find the older element
                if let cacheIndex = userProfileCache.index(forKey: thisUid) {
                    userProfileCache.remove(at: cacheIndex) //delete it
                }
                userProfileCache[thisUid] = thisUser    //update cache
                self.userprofile = userProfileCache[thisUid]
                completion(self.userprofile!, nil)
            }
        }, withCancel: nil)
    }

    //action to update gender
    @IBAction func genderPopupAction(_ sender: Any) {
        let genderPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "genderPopup") as! genderPopupView
        self.addChildViewController(genderPopupVC)  //add new vc ontop of current vc
        genderPopupVC.view.frame = self.view.frame
        self.view.addSubview(genderPopupVC.view)
        genderPopupVC.didMove(toParentViewController: self)
    }
    
    //update age
    @IBAction func agePopupAction(_ sender: Any) {
        let agePopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "agePopup") as! ageVC
        self.addChildViewController(agePopupVC)  //add new vc ontop of current vc
        agePopupVC.view.frame = self.view.frame
        self.view.addSubview(agePopupVC.view)
        agePopupVC.didMove(toParentViewController: self)
    }
    
    //update website
    @IBAction func websitePopupAction(_ sender: Any) {
        let webPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "websitePopup") as! websiteVC
        self.addChildViewController(webPopupVC)  //add new vc ontop of current vc
        webPopupVC.view.frame = self.view.frame
        self.view.addSubview(webPopupVC.view)
        webPopupVC.didMove(toParentViewController: self)
    }
    
    //update experience
    @IBAction func experiencePopupAction(_ sender: Any) {
        let expPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "experiencePopup") as! experienceVC
        self.addChildViewController(expPopupVC)  //add new vc ontop of current vc
        expPopupVC.view.frame = self.view.frame
        self.view.addSubview(expPopupVC.view)
        expPopupVC.didMove(toParentViewController: self)
    }
    
    //update user profile image
    @IBAction func chooseProfileAction(_ sender: Any) {
        self.handleSelectProfileImageVie()
    }
    
    //update user's level
    @IBAction func chooseLevel(_ sender: Any) {
        let pickerPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickerPopup") as! levelPicker
        self.addChildViewController(pickerPopupVC)  //add new vc ontop of current vc
        pickerPopupVC.view.frame = self.view.frame
        self.view.addSubview(pickerPopupVC.view)
        pickerPopupVC.didMove(toParentViewController: self)
    }
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
