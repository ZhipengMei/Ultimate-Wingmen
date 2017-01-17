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
    
//    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var emailAddress: UILabel!
    @IBOutlet var gender: UILabel!
    @IBOutlet var website: UILabel!
    @IBOutlet var yearsInGame: UILabel!
    @IBOutlet var age: UILabel!
    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

//        //add tapgesture and call hidekeyboard function
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableVC.hideKeyboard))
//        tapGesture.cancelsTouchesInView = true
//        tableView.addGestureRecognizer(tapGesture)
        
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

            }//end if
        }//end observeHelper
        
    }//end view did load
    
    //update the user profile and save it into cache
    var userprofile: User?    //reset the variable
    func updateProfile(thisUid: String, completion: @escaping (User?, Error?) -> Void) {
        let thisref = FIRDatabase.database().reference().child("user_profile").child((user?.uid)!)
        //keep observing
        thisref.observe(.value, with: { (snapshot) in
            if let snapDict = snapshot.value as? NSDictionary{
                let thisUser = User(dict: snapDict as! [String : NSObject])
                userProfileCache[thisUid] = thisUser    //update cache
                self.userprofile = userProfileCache[thisUid]
                completion(self.userprofile!, nil)
            }
        }, withCancel: nil)
    }
  
    //updating user info to firebase
    @IBAction func onUpdate(_ sender: Any) {

//        self.activityIndicator.startAnimating()
        
//        var index = 0
//        while index < about.count {
//            
//            let indexPath = NSIndexPath(row: index, section: 0)
//            let cell: TextInputCell = self.tableView.cellForRow(at: indexPath as IndexPath) as! TextInputCell
//            
//            if (cell.myTextField.text != "") {
//                let item:String = (cell.myTextField.text!)
//
//                switch (about[index]) {
//                case "Username":
//                    //self.ref.child("user_profile").child("\(user!.uid)/username").setValue(item)
//                    
//                    //changing current user's displayname
//                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
//                    changeRequest?.displayName = item
//                    changeRequest?.commitChanges() { (error) in
//                        print("Successfully updated username to \(self.user?.displayName)")
//                    }
//                    
//                case "Age":
//                    self.ref.child("user_profile").child("\(user!.uid)/age").setValue(item)
//                case "Gender":
//                    self.ref.child("user_profile").child("\(user!.uid)/gender").setValue(item)
//                    
//                case "Years in Game":
//                    self.ref.child("user_profile").child("\(user!.uid)/years_in_game").setValue(item)
//                    
//                case "Website":
//                    self.ref.child("user_profile").child("\(user!.uid)/website").setValue(item)
//                    
//                case "Email":
//                    self.ref.child("user_profile").child("\(user!.uid)/email").setValue(item)
//                    
//                default:
//                    print("Do not update")
//                } //end switch
//            }//end if
//            index += 1
//        }//end while
        
//        observeHelper.loadUserProfileUsingCache(thisUid: user!.uid) { (userprofile, error) in
//            
//        }

//        self.activityIndicator.stopAnimating()
    }

    //action to update gender
    @IBAction func genderPopupAction(_ sender: Any) {
        let genderPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "genderPopup") as! genderPopupView
        self.addChildViewController(genderPopupVC)  //add new vc ontop of current vc
        genderPopupVC.view.frame = self.view.frame
        self.view.addSubview(genderPopupVC.view)
        genderPopupVC.didMove(toParentViewController: self)
    }
    
    
    @IBAction func agePopupAction(_ sender: Any) {
        let agePopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "agePopup") as! ageVC
        self.addChildViewController(agePopupVC)  //add new vc ontop of current vc
        agePopupVC.view.frame = self.view.frame
        self.view.addSubview(agePopupVC.view)
        agePopupVC.didMove(toParentViewController: self)
    }
    
    @IBAction func websitePopupAction(_ sender: Any) {
        let webPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "websitePopup") as! websiteVC
        self.addChildViewController(webPopupVC)  //add new vc ontop of current vc
        webPopupVC.view.frame = self.view.frame
        self.view.addSubview(webPopupVC.view)
        webPopupVC.didMove(toParentViewController: self)
    }
    
    @IBAction func experiencePopupAction(_ sender: Any) {
        let expPopupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "experiencePopup") as! experienceVC
        self.addChildViewController(expPopupVC)  //add new vc ontop of current vc
        expPopupVC.view.frame = self.view.frame
        self.view.addSubview(expPopupVC.view)
        expPopupVC.didMove(toParentViewController: self)
    }
    
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    //dismiss keyboard
//    func hideKeyboard() {
//        self.tableView.endEditing(true)
//    }




}
