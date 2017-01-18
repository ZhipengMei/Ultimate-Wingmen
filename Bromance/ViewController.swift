//
//  ViewController.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/1/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var myView: UIView!   //myView holds login buttons

    override func viewDidLoad() {
        super.viewDidLoad()
        myView.isHidden = false
        self.setupFacebookButtons()
        self.setupGoogleButtons()
        self.setupaTwitterButtons()

    }


    
    //***google button***
    fileprivate func setupGoogleButtons() {
        //adding google sign in button
        //add google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 270, width: view.frame.width - 32, height: 50)
        myView.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    //***twitter button***
    fileprivate func setupaTwitterButtons() {
        let twitterButton = TWTRLogInButton { (session, error) in
            self.myView.isHidden = true
            self.activityIndicator.startAnimating()  //shows spinner animation
            
            if let err = error {
                self.myView.isHidden = false
                self.activityIndicator.stopAnimating()
                print("Failed to login via Twitter: ", err)
                return
            }

            print("Successfully log in under Twitter...")
            
            guard let token = session?.authToken else {return}
            guard let secret = session?.authTokenSecret else {return}
            let credential = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            
            FIRAuth.auth()?.signIn(with: credential, completion: {(user,error) in
                if let err = error {
                    self.myView.isHidden = false
                    self.activityIndicator.stopAnimating()
                    print("Failed to login to Firebase with Twitter", err)
                    return
                }
                self.storeInfoFirstLogin()   //store new user's data
                print("successfully created a firebase twitter user", user?.uid ?? "")
            })
        }
        myView.addSubview(twitterButton)    //added button to myView
        twitterButton.frame = CGRect(x: 16, y: 332 , width: view.frame.width - 32, height: 50)
    }
    
    
    //facebook button
    fileprivate func setupFacebookButtons() {
        //adding facebook sign in button
        let loginButton = FBSDKLoginButton()
        myView.addSubview(loginButton)      //added button to myView
        //frame's are obselete, please use constraints instead because its 2016 after all
        loginButton.frame = CGRect(x: 16, y: 205, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
    }
    //facebook logoutbutton
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    //facebook login button
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.myView.isHidden = true
        activityIndicator.startAnimating()  //shows spinner animation
        if error != nil {
            print(error)
            self.myView.isHidden = false
            activityIndicator.stopAnimating()
            return
        } else if(result.isCancelled){
            activityIndicator.stopAnimating()
            self.myView.isHidden = false
        }
        showEmailAddress()
    }
    
    // get facebook user's basic info from social media account
    func showEmailAddress() {
        //setup facebook access token
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        //using access token to grab user credential
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            self.storeInfoFirstLogin()   //store new user's data
            print("Successfully logged in with our user: ", user ?? "")
        })
        
        
        // using credential to grab user's data
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request:", err!)
                return
            }
            print(result!)
        }
    }
    
    
//    //***user choose email and passowrd signup method***
//    @IBAction func CreateAccount(_ sender: UIButton) {
//        FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: {
//            user, error in
//            
//            self.myView.isHidden = true
//            self.activityIndicator.startAnimating()
//            
//            //if user is already existed
//            if error != nil {
//                self.login()
//                self.activityIndicator.stopAnimating()
//            }
//            else {
//                print("User Created")
//                self.login()
//                self.storeInfoFirstLogin()   //store new user's data
//                self.activityIndicator.stopAnimating()
//                self.performSegue(withIdentifier: "setup_Username_Segue", sender: nil)
//            }
//            
//        })
//    }
    
//    //user login function
//    func login() {
//        FIRAuth.auth()?.signIn(withEmail: (emailField).text!, password: passwordField.text!, completion: {
//            user, error in
//
//            if error != nil {
//                print("Incorrect")
//            }
//            else {
//                print("Yeahhhh")
//            }
//        })
//    }
    //***user choose email and passowrd signup method end ***
    
    
    

    //onTap hides the keyboard
//    @IBAction func onTap(_ sender: Any) {
//        view.endEditing(true)
//    }
    //google button bug
    // due to tab-gesture dismiss keyboard, tab-gesture would mess up google button


    
    //store user's basic info on the very first login
    func storeInfoFirstLogin() {
        print("inside first login in")
        if let user = FIRAuth.auth()?.currentUser {
            print("inside first login in/ current user")

            //firebase storage to store media files
            let storageRef = FIRStorage.storage().reference(forURL: "gs://bromance-e91d8.appspot.com")
            let profilePicRef = storageRef.child(user.uid + "/profile_pic_small.jpg")
            //store the userID
            let userID = user.uid
            //firebase databse to store informations
            let databaseRef = FIRDatabase.database().reference()
            let profileImageRef = databaseRef.child("user_profile").child(userID).child("profile_pic_small")
            
            profileImageRef.observe(.value, with: {(snapshot) in
                
                let profile_pic = snapshot.value as? String
                
                //download image from facebook only if when profile image does not exist
                //then upload to firebase, store that firebase storage url to user_profile image
                if(profile_pic == nil) {
                    //print("profile image is nil inside VC")
                    //*** getting picture from facebook ***
                    let fbprofileImage = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":300,"width":300,"redirect":false], httpMethod:"GET")
                    
                    fbprofileImage?.start(completionHandler: {(connection, result, error) -> Void in

                        if(error == nil) {
                            let dictionary = result as? NSDictionary        //store JSON result as a dictionary
                            let data = dictionary?.object(forKey: "data") //go inside the data node
                            let urlPic = ((data as AnyObject).object(forKey:"url"))! as! String//get the image url
                            
                            if let imageData = NSData(contentsOf: NSURL(string: urlPic)! as URL){
                                profilePicRef.put(imageData as Data, metadata: nil){  //upload profile image into firebase
                                    metadata,error in
                                    if(error == nil) {
                                        //size, content type or the download url
                                        let downloadUrl = metadata!.downloadURL
                                        //print("downloadUrl is")
                                        //print(downloadUrl()!.absoluteString)
                                        profileImageRef.setValue(downloadUrl()!.absoluteString)
                                    } else {
                                        print("Error in downloading image")
                                    }
                                }
                            }//end if
                        }//end if
                    })// *** getting picture from facebook end ***
                    
                    if(profile_pic == nil){
                        //print("profile pic still nill")
                        let imageUrl = user.photoURL
                        
                        if let imageData = NSData(contentsOf: imageUrl!){
                            profilePicRef.put(imageData as Data, metadata: nil){  //upload profile image into firebase
                                metadata,error in
                                if(error == nil) {
                                    //size, content type or the download url
                                    let downloadUrl = metadata!.downloadURL
                                    //print("downloadUrl is")
                                    //print(downloadUrl()!.absoluteString)
                                    profileImageRef.setValue(downloadUrl()!.absoluteString)
                                } else {
                                    print("Error in downloading image")
                                }
                            }
                        }//end if
                        
                        
                    }//end if profile_pic still nil
                    
                } //end if
                
                databaseRef.child("user_profile").child("\(user.uid)/username").setValue(user.displayName)
                databaseRef.child("user_profile").child("\(user.uid)/age").setValue("")
                databaseRef.child("user_profile").child("\(user.uid)/gender").setValue("")
                databaseRef.child("user_profile").child("\(user.uid)/years_in_game").setValue("")
                databaseRef.child("user_profile").child("\(user.uid)/website").setValue("")
                databaseRef.child("user_profile").child("\(user.uid)/level").setValue("")
                if let email = user.email {
                    databaseRef.child("user_profile").child("\(user.uid)/email").setValue(email)
                } else {
                    databaseRef.child("user_profile").child("\(user.uid)/email").setValue("")
                }
            
            })//end databaseRef.child("user_profile")
        }//end if FIRAuth.auth()?.currentUser
    }//end storeInfoFirstLogin
  
}

