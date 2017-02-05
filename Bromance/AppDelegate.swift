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
//import GoogleMaps
import CoreLocation
import GeoFire
import FirebaseMessaging
import UserNotifications
import SVProgressHUD


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var storyboard = UIStoryboard(name: "Main", bundle: nil)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Twitter.self]) //twitter fabric
        FIRApp.configure()  //firebase
        //google sign in
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        //facebook sign in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)


        
        //badge icon unread message 
//        UIApplication.shared.applicationIconBadgeNumber = 0;

        
        //load onboarding screen only once
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "onboarding")
        //checking onboardingComplete or not
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "onboardingComplete") {
            userpersist()
            
            //create the notificationCenter
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            // set the type as sound or badge
            center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in }
            application.registerForRemoteNotifications()
            
        } else {
            //otherwise show onboarding view
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }

        //change tab bar tint clor
        UITabBar.appearance().tintColor = UIColor(red: 123/255, green: 179/255, blue: 46/255, alpha: 1)
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        UINavigationBar.appearance().tintColor = UIColor.white
        
        return true
    }
    
    func userpersist() {
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
//                    GMSServices.provideAPIKey("AIzaSyCAnbg9kemfC5bWugXYsDllQeeAJXqs_pc")    //google map api key
                    let tabVC = self.storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    self.window?.rootViewController = tabVC
                }
            } else { //login in if user not found
                print("*** Please login ***")
                let tabVC = self.storyboard.instantiateViewController(withIdentifier: "loginStoryboard")
                self.window?.rootViewController = tabVC
            }
        }
    }
    
    
    
    
    
    //google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        SVProgressHUD.show() //animate indicator
        
        if let err = error {
            print("Failed to log into Google: ", err)
            return
        }
        
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
            //go to tab
            let tabVC = self.storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            SVProgressHUD.dismiss()
            self.window?.rootViewController = tabVC
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
    
    
    
//    //remote notification
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        
//        print("Message Id : \(userInfo["gcm_message_id"]!)")
//        print(userInfo)
//        
//    }
//    //notification fail
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print(error)
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        print("\(notification.request.content.userInfo)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
    }


}

