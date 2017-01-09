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
            let storage = FIRStorage.storage()
            let storageRef = storage.reference(forURL: "gs://bromance-e91d8.appspot.com")
            let profilePicRef = storageRef.child(user.uid + "/profile_pic_small.jpg")
            
            //store the userID
            let userID = user.uid
            
            //firebase databse to store informations
            let databaseRef = FIRDatabase.database().reference()
            
            databaseRef.child("user_profile").child(userID).child("profile_pic_small").observe(.value, with: {
                (snapshot) in
                
                let profile_pic = snapshot.value as? String
                if(profile_pic == nil)
                {
                    if let imageData = NSData(contentsOf: user.photoURL!)
                    {
                        //upload profile image into firebase
                        profilePicRef.put(imageData as Data, metadata: nil)
                        {
                            metadata,error in
                            if(error == nil)
                            {
                                //size, content type or the download url
                                let downloadUrl = metadata!.downloadURL
                                databaseRef.child("user_profile").child("\(user.uid)/profile_pic_small").setValue(downloadUrl()!.absoluteString)
                            } else {
                                print("Error in downloading image")
                            }
                        }//end profilePicRef.put
                    } else { //else use default image   
                        print("settting up default image as user profile")
                        let imageData = NSData(contentsOf: NSURL(string: "https://firebasestorage.googleapis.com/v0/b/bromance-e91d8.appspot.com/o/default%2Fprofile_pic_small.jpg?alt=media&token=02d85d91-ac43-4a0b-a8f6-32b0821b51e4")! as URL)
                        
                        //upload profile image into firebase
                        profilePicRef.put(imageData as! Data, metadata: nil)
                        {
                            metadata,error in
                            if(error == nil)
                            {
                                //size, content type or the download url
                                let downloadUrl = metadata!.downloadURL
                                databaseRef.child("user_profile").child("\(user.uid)/profile_pic_small").setValue(downloadUrl()!.absoluteString)
                            } else {
                                print("Error in downloading image")
                            }
                        }//end profilePicRef.put
            
                    }

                    databaseRef.child("user_profile").child("\(user.uid)/username").setValue(user.displayName)
                    databaseRef.child("user_profile").child("\(user.uid)/age").setValue("")
                    databaseRef.child("user_profile").child("\(user.uid)/gender").setValue("")
                    databaseRef.child("user_profile").child("\(user.uid)/years_in_game").setValue("")
                    databaseRef.child("user_profile").child("\(user.uid)/website").setValue("")
                    databaseRef.child("user_profile").child("\(user.uid)/email").setValue(user.email)
                    
                } else {
                    print("user has logged in earlier")
                }
            })//end databaseRef.child("user_profile")
        }
    
    }

    
    
    
    
    
}

