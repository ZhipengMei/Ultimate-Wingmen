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

class ProfileVC: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var messageBtn: UIButton!
    @IBOutlet var moreBtn: UIBarButtonItem!

    @IBOutlet var bg: UIImageView!

    let transition = CircularTransition() //custom animation
    
    var userID: String? //target user's id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2  //circular image
        self.profilePic.clipsToBounds = true
        
        //making sure userID has something
        if self.userID == nil {
            self.userID = FIRAuth.auth()?.currentUser?.uid
        }
        
        if self.userID != nil { //other user viewing
            //function to download user profile or use existing
            observeHelper.loadUserProfileUsingCache(thisUid: userID!) { (userprofile, error) in
                if error != nil {
                    print("observeHelper error: \(error!)")
                } else {
                    // do something with the userprofile
                    self.username.text = userprofile?.username   //display username

                    // do something with the userprofile
                    if let profileUrl = userprofile?.profile_pic_small {
                        self.profilePic.loadImageUsingCache(urlString: profileUrl)
                        self.bg.loadImageUsingCache(urlString: profileUrl)
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
            self.moreBtn.isEnabled = false
        } else {
            self.messageBtn.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //hide message/more buttons
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.messageBtn.isHidden = true
        self.moreBtn.isEnabled = true
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
