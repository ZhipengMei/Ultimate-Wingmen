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

class EditProfileTableVC: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
//    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var emailAddress: UILabel!
    @IBOutlet var gender: UILabel!
    @IBOutlet var website: UILabel!
    @IBOutlet var yearsInGame: UILabel!
    @IBOutlet var age: UILabel!
    
    var genderData = ["Man", "Woman"]
    var picker = UIPickerView()
    
    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        picker.dataSource = self
        picker.delegate = self
        
        
        //add tapgesture and call hidekeyboard function
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        
        //retrieving user basic info data from firebase
        //function to download user profile or use existing
        observeHelper.loadUserProfileUsingCache(thisUid: (user?.uid)!) { (userprofile, error) in
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
    
    
    //picker view for gender
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderData.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.gender.text = genderData[row]
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderData[row]
    }

//    
//    //xib subview for gender
//    var myCustomView: EditProfileTableVC? // declare variable inside your controller
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if myCustomView == nil { // make it only once
//            myCustomView = Bundle.main.loadNibNamed("EditProfileTableVC", owner: self, options: nil)?.first as? EditProfileTableVC
//            myCustomView.
//            
//            self.view.addSubview(myCustomView) // you can omit 'self' here
//            // if your app support both Portrait and Landscape orientations
//            // you should add constraints here
//        }
//    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //dismiss keyboard
    func hideKeyboard() {
        self.tableView.endEditing(true)
    }




}
