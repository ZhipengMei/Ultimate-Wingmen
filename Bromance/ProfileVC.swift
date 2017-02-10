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
import FirebaseDatabase

class ProfileVC: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var messageBtn: UIButton!
    @IBOutlet var moreBtn: UIBarButtonItem!
    @IBOutlet var bg: UIImageView!
    let transition = CircularTransition() //custom animation
    var userID: String? //target user's id
    var currentLoggedInUserId: String!
    let rootRef = FIRDatabase.database().reference()    //databse root reference
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLoggedInUserId = FIRAuth.auth()?.currentUser?.uid
        
        //making sure userID has something
        if self.userID == nil {
            self.userID = FIRAuth.auth()?.currentUser?.uid
        }

        //decided to leave this feature out because nobody wants to see a blocked title
//        //change message button title
//        if UserDefaults.standard.object(forKey: "blocking") != nil {
//            if let blocking = UserDefaults.standard.object(forKey: "blocking")! as? Bool {
//                if blocking == true {
//                    self.messageBtn.setTitle("Blocked", for: .normal)
//                    self.messageBtn.isUserInteractionEnabled = false
//                } else {
//                    self.messageBtn.isUserInteractionEnabled = true
//                    self.messageBtn.setTitle("Message", for: .normal)
//                }
//            }
//        }

        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2  //circular image
        self.profilePic.clipsToBounds = true
        
        
        if (self.userID != nil && self.currentLoggedInUserId != nil)  { //other user viewing
            print("self.userID \(self.userID)")
            print("self.currentLoggedInUserId \(self.currentLoggedInUserId)")
            //change the more item name to block if user viewing another user's profile
            //if the ids matched means the same user viewing his own profile
            if self.userID == currentLoggedInUserId {
                self.moreBtn.title = "More"
            } else {
                //otherwise user is viewing another user's profile
                self.moreBtn.title = "Report"
            }
            
            //function to download user profile or use existing
            observeHelper.loadUserProfileUsingCache(thisUid: userID!) { (userprofile, error) in
                if error != nil {
                    print("observeHelper error: \(error!)")
                } else {
                    // do something with the userprofile
                    self.username.text = userprofile?.username?.components(separatedBy: " ")[0]

                    // do something with the userprofile
                    if let profileUrl = userprofile?.profile_pic_small! {
                        self.profilePic.loadImageUsingCache(urlString: URL(string: profileUrl)!)
                        self.bg.loadImageUsingCache(urlString: URL(string:profileUrl)!)
                    }
                }
            }//end observeHelper
        }//end if

        //add tapgesture to title view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.detailInfo))
        tapGesture.cancelsTouchesInView = true
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(tapGesture)

    }//end view did load

    

    
    //animate to detail info view
    func detailInfo() {
        if let detailInfoprofile = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailInfo") as? detailInfoVC {
            
            detailInfoprofile.transitioningDelegate = self
            detailInfoprofile.modalPresentationStyle = .custom
            detailInfoprofile.userID = self.userID //passing the profile user id
            
            if let navigator = self.navigationController {
                navigator.present(detailInfoprofile, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //show message/more button if current user it himself
        if self.userID != FIRAuth.auth()?.currentUser?.uid {
            self.messageBtn.isHidden = false
            self.tabBarController?.tabBar.isHidden = true

        } else {
            self.messageBtn.isHidden = true
        }
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
        rootRef.removeAllObservers() //remove firebase database observer
    }
    
    //hide message/more buttons
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.messageBtn.isHidden = true
//        self.moreBtn.isEnabled = true
    }
    

    @IBAction func sendMessage(_ sender: Any) {
        guard let sendId = FIRAuth.auth()?.currentUser?.uid else { return }
        
        //function to download user profile or use existing
        observeHelper.loadUserProfileUsingCache(thisUid: userID!) { (userprofile, error) in
            if error != nil {
                print("observeHelper error: \(error!)")
            } else {
                // do something with the userprofile
                if let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as? ChatViewController {
                    chatVC.senderId = sendId
                    chatVC.senderDisplayName = userprofile?.username
                    chatVC.receiverId = self.userID
                    if let navigator = self.navigationController {
                        navigator.pushViewController(chatVC, animated: true)
                    }
                }
            }
        }//end observeHelper
    }

    
    // custom animation code
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = profilePic.center
        transition.circleColor = profilePic.backgroundColor!
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = profilePic.center
        transition.circleColor = profilePic.backgroundColor!
        
        return transition
    }
    
    


    //change the user block status
    @IBAction func checkParameter(_ sender: Any) {
        //print("userID: \(self.userID)")
        //print("currentLoggedInUserId: \(currentLoggedInUserId)")
        
        //if the ids matched means the same user viewing his own profile
        if self.userID == currentLoggedInUserId {
            if let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileDetailVC") as? ProfileDetailViewController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(detailVC, animated: true)
                }
            }
        } else {
            //otherwise user is viewing another user's profile
            let ref = self.rootRef.child("user_profile").child(currentLoggedInUserId!).child("blocked").child(self.userID!)
                ref.observeSingleEvent(of: .value, with: {
                    snapshot in
                    //checking the return package has content
                    if let blockBool = snapshot.value as? Bool {
                        //print(snapshot.value!)
                        //uis not on blockedlist yet
                        if blockBool {
                            //print(snapshot.value!)
                            self.unBlockUser(id: self.currentLoggedInUserId!)
                        } else {
                            self.blockUser(id: self.currentLoggedInUserId!)
                        }
                    } else {
                        //return package is null
                        //print(snapshot.value!)
                        self.blockUser(id: self.currentLoggedInUserId!)
                    }
                    
                })//end ref
            

        }
    }
    
    //blocking user
    func blockUser(id: String) {
        
        // create the alert
        let alert = UIAlertController(title: "uh-oh", message: "You are about to block/report this user?", preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Block", style: UIAlertActionStyle.default, handler: {
            action in
            
            //add this user's uid to blockedlist
//            UserDefaults.standard.setValue(true, forKey: "blocking")
//            self.messageBtn.setTitle("Blocked", for: .normal)
//            self.messageBtn.isUserInteractionEnabled = false

            self.rootRef.child("user_profile").child(id).child("blocked").child(self.userID!).setValue(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func unBlockUser(id: String){
        // create the alert
        let alert = UIAlertController(title: "uh-oh", message: "You are about to be friend with this user again?", preferredStyle: UIAlertControllerStyle.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Ayee", style: UIAlertActionStyle.default, handler: {
            action in
            
            //add this user's uid to blockedlist
//            UserDefaults.standard.setValue(false, forKey: "blocking")
//
//            self.messageBtn.isUserInteractionEnabled = true
//            self.messageBtn.setTitle("Message", for: .normal)
            self.rootRef.child("user_profile").child(id).child("blocked").child(self.userID!).setValue(false)

        }))
        alert.addAction(UIAlertAction(title: "Nope", style: UIAlertActionStyle.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
