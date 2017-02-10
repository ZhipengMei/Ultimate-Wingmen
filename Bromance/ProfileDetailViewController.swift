//
//  ProfileDetailViewController.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/26/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKCoreKit
import TwitterKit
import GoogleSignIn
import MessageUI

class ProfileDetailViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    //store the device id
    let deviceID = UIDevice.current.identifierForVendor?.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onLogout(sender: AnyObject) {
        
        //update user online status
        let userID = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        let myConnectionsRef = ref.child("user_profile").child("\(userID!)").child("connections").child("\(self.deviceID!)")
        //saving data with completion block
        myConnectionsRef.child("online").setValue(false, withCompletionBlock: { (error: Error?, _:FIRDatabaseReference) in
            //Code
            myConnectionsRef.child("last_online").setValue(NSDate().timeIntervalSince1970, withCompletionBlock: { (error: Error?, _:FIRDatabaseReference) in
                //Code
                
                //signs the user out of the Firebase app
                try! FIRAuth.auth()!.signOut()
                
                //sign the user out of the facebook app
                FBSDKAccessToken.setCurrent(nil)
                
                //sign the user out of the google app
                GIDSignIn.sharedInstance().signOut()
                
                
                //        //sign the user out of the twitter
                //        let client = TWTRAPIClient.withCurrentUser()
                //        Twitter.sharedInstance().sessionStore.logOutUserID(client.userID!)
                
                print("User logged out successfully")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "loginStoryboard")
                self.present(controller, animated: true, completion: nil)
            })
        })
        
    }
    
    @IBAction func onReportProblem(_ sender: Any) {
        let mailComposeViewController = issueConfiguredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func onFeedBack(_ sender: Any) {
        let mailComposeViewController = feedbackConfiguredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    
    // *** Send Email ***
    
    //report problem email setup
    func issueConfiguredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["teamacorne@gmail.com"])
        mailComposerVC.setSubject("Report a Problem")
        mailComposerVC.setMessageBody("I am having the following issue(s): ", isHTML: false)
        
        return mailComposerVC
    }
    
    //feedback email setup
    func feedbackConfiguredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["teamacorne@gmail.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("Let us know what you enjoy the most about Bromance", isHTML: false)
        
        return mailComposerVC
    }
    
    
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "Could Not Send Email!", message:"Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        self.present(alert, animated: true){}
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    // *** send meial end ***

    


}
