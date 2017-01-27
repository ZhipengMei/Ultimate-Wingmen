//
//  detailInfoVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/27/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseAuth

class detailInfoVC: UIViewController {

    @IBOutlet var dismissButton: UIButton!
    
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!
    var userID: String? //target user's id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //circular button
        dismissButton.layer.cornerRadius = dismissButton.frame.size.width / 2
        //dispaly data
        self.getProfileData()
        
    }
    
    func getProfileData() {
        self.ageLabel.isHidden = true
        self.levelLabel.isHidden = true
        self.websiteLabel.isHidden = true
        
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
                    if userprofile?.age != "" {
                        self.ageLabel.isHidden = false
                        self.ageLabel.text = "Age: \((userprofile?.age)!)"
                    }
                    if userprofile?.website != "" {
                        self.websiteLabel.isHidden = false
                        self.websiteLabel.text = userprofile?.website
                    }
                    if userprofile?.level != "" {
                        self.levelLabel.isHidden = false
                        self.levelLabel.text = "Level: \((userprofile?.level)!)"
                    }
                }
            }//end observeHelper
        }//end if
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

    }

    @IBAction func dismissSecondVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
