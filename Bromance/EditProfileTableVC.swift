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
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var about = ["Username","Age","Gender","Years in Game", "Website","Email"]
    var ref = FIRDatabase.database().reference()
    
    var user = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add tapgesture and call hidekeyboard function
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditProfileTableVC.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        
        //retrieving user basic info data from firebase
        //function to download user profile or use existing
        observeHelper.loadUserProfileUsingCache(thisUid: (user?.uid)!) { (userprofile, error) in
            if error == nil {
                
                print(userprofile?.username)
                
//                //using while loop to update each item
//                var index = 0
//                while index < self.about.count {
//                    
//                    let indexPath = NSIndexPath(row: index, section: 0)
//                    let cell: TextInputCell = self.tableView.cellForRow(at: indexPath as IndexPath) as! TextInputCell
//                    
//                    let field:String = (cell.myTextField.placeholder)!
//                    
//                    //(userDetails as AnyObject).object(forKey: "username")
//                    switch (field) {
//                    case "Username":
//                        //cell.configure(text: userDetails.object(forKey: "username") as? String , placeholder: "username", labelText: "username")
//                        
//                        cell.configure(text: self.user?.displayName , placeholder: "username?", labelText: "username")
//                        
//                    case "Age":
//                        cell.configure(text: userprofile?.age , placeholder: "Age?", labelText: "Age")
//                        
//                    case "Gender":
//                        cell.configure(text: userprofile?.gender , placeholder: "Gender?", labelText: "Gender")
//                        
//                    case "Years in Game":
//                        cell.configure(text: userprofile?.years_in_game , placeholder: "Years in Game?", labelText: "Years in Game")
//                        
//                    case "Website":
//                        cell.configure(text: userprofile?.website , placeholder: "Website?", labelText: "Website")
//                        
//                    case "Email":
//                        cell.configure(text: self.user?.email , placeholder: "Email?", labelText: "Email")
//                        
//                    default:
//                        print("Do not update")
//                    } //end switch
//                    index += 1
//                }//end while
                
            }//end if
        }//end observeHelper
        
        


//        //retrieving user basic info data from firebase
//        _ = self.ref.child("user_profile").observe(FIRDataEventType.value, with: {(snapshot) in
//            
//            let usersDict = snapshot.value as! NSDictionary
//            print(usersDict)
//            let userDetails = usersDict.object(forKey: self.user?.uid as Any) as! NSDictionary
//            //using while loop to update each item
//            var index = 0
//            while index < self.about.count {
//                
//                let indexPath = NSIndexPath(row: index, section: 0)
//                let cell: TextInputCell = self.tableView.cellForRow(at: indexPath as IndexPath) as! TextInputCell
//                
//                let field:String = (cell.myTextField.placeholder)!
//                
//                //(userDetails as AnyObject).object(forKey: "username")
//                    switch (field) {
//                    case "Username":
//                        //cell.configure(text: userDetails.object(forKey: "username") as? String , placeholder: "username", labelText: "username")
//
//                        cell.configure(text: self.user?.displayName , placeholder: "username?", labelText: "username")
//
//                        
//                    case "Age":
//                        cell.configure(text: userDetails.object(forKey: "age") as? String , placeholder: "Age?", labelText: "Age")
//                        
//                    case "Gender":
//                        cell.configure(text: userDetails.object(forKey: "gender") as? String , placeholder: "Gender?", labelText: "Gender")
//                        
//                    case "Years in Game":
//                        cell.configure(text: userDetails.object(forKey: "years_in_game") as? String , placeholder: "Years in Game?", labelText: "Years in Game")
//                        
//                    case "Website":
//                        cell.configure(text: userDetails.object(forKey: "website") as? String , placeholder: "Website?", labelText: "Website")
//                        
//                    case "Email":
//                        cell.configure(text: self.user?.email , placeholder: "Email?", labelText: "Email")
//                        
//                    default:
//                        print("Do not update")
//                    } //end switch
//                index += 1
//            }//end while
//
//        
//        })
        
        
    }//end view did load



  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextInput", for: indexPath) as! TextInputCell

        cell.configure(text: "", placeholder: "\(about[indexPath.row])", labelText: "\(about[indexPath.row])")


        return cell
    }
  
    //updating user info to firebase
    @IBAction func onUpdate(_ sender: Any) {

        self.activityIndicator.startAnimating()
        
        var index = 0
        while index < about.count {
            
            let indexPath = NSIndexPath(row: index, section: 0)
            let cell: TextInputCell = self.tableView.cellForRow(at: indexPath as IndexPath) as! TextInputCell
            
            if (cell.myTextField.text != "") {
                let item:String = (cell.myTextField.text!)

                switch (about[index]) {
                case "Username":
                    //self.ref.child("user_profile").child("\(user!.uid)/username").setValue(item)
                    
                    //changing current user's displayname
                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = item
                    changeRequest?.commitChanges() { (error) in
                        print("Successfully updated username to \(self.user?.displayName)")
                    }
                    
                case "Age":
                    self.ref.child("user_profile").child("\(user!.uid)/age").setValue(item)
                case "Gender":
                    self.ref.child("user_profile").child("\(user!.uid)/gender").setValue(item)
                    
                case "Years in Game":
                    self.ref.child("user_profile").child("\(user!.uid)/years_in_game").setValue(item)
                    
                case "Website":
                    self.ref.child("user_profile").child("\(user!.uid)/website").setValue(item)
                    
                case "Email":
                    self.ref.child("user_profile").child("\(user!.uid)/email").setValue(item)
                    
                default:
                    print("Do not update")
                } //end switch
            }//end if
            index += 1
        }//end while
        
//        observeHelper.loadUserProfileUsingCache(thisUid: user!.uid) { (userprofile, error) in
//            
//        }

        self.activityIndicator.stopAnimating()
    }
    

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return about.count
    }
    //dismiss keyboard
    func hideKeyboard() {
        self.tableView.endEditing(true)
    }




}
