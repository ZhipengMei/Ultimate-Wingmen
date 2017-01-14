//
//  AppDelegate.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/1/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import Fabric
import TwitterKit
import GoogleMaps
import CoreLocation
import GeoFire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Twitter.self])
        
        FIRApp.configure()

        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        
        //user persist *** important ***
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            //check user existence
            if user != nil {
                //check displayName object existence
                if (user?.displayName == nil || user?.displayName == ""){
                    print("*** no username object ***")
                    let tabVC = self.storyboard.instantiateViewController(withIdentifier: "setupUsernamceVC")
                    self.window?.rootViewController = tabVC
                } else { //else set up a new username
                    print("***logged in as \(user?.displayName)***")
                    //transition to tab bar when username is found
                    let tabVC = self.storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    self.window?.rootViewController = tabVC
                }
            } else { //login in if user not found
                print("*** Please login ***")
                let tabVC = self.storyboard.instantiateViewController(withIdentifier: "loginStoryboard")
                self.window?.rootViewController = tabVC
            }
        }
        
        GMSServices.provideAPIKey("AIzaSyCAnbg9kemfC5bWugXYsDllQeeAJXqs_pc")    //google map api key

        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to log into Google: ", err)
            return
        }
        
        print("Successfully logged into Google", user)
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            ViewController().storeInfoFirstLogin()          //calling function from another class
            print("Successfully logged into Firebase with Google", uid)
        })
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return handled
    }

    
   
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    //update user's location every hour
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

