//
//  usernameVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/17/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class usernameVC: UIViewController {

    @IBOutlet var usernameField: UITextField!
    let databaseRef = FIRDatabase.database().reference()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // "next" button
    @IBAction func validateUsername(_ sender: UIButton) {
        setUsername()
    }
    
    
    //setup username everyfirst time signin
    func setUsername(){
        let user = FIRAuth.auth()?.currentUser
        print("Current user is \(user)")

        //if displayName is not exist
        if (user?.displayName == nil || user?.displayName == ""){
            //setup new username
            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
            changeRequest?.displayName = usernameField.text
            changeRequest?.commitChanges() { (error) in
                self.databaseRef.child("user_profile").child("\(user?.uid)/username").setValue(user?.displayName)
                print("Successfully updated username to \(user?.displayName)")
                self.performSegue(withIdentifier: "toTabBarController", sender: nil)
            }
        }

    }
    
    
    //onTap hides the keyboard
    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
    }



}
