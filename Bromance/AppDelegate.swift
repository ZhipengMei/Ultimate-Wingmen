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
        
        UNUserNotificationCenter.current().delegate = self
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
        
        
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
                    //GMSServices.provideAPIKey("AIzaSyCAnbg9kemfC5bWugXYsDllQeeAJXqs_pc")    //google map api key
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
        FIRMessaging.messaging().disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    //remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Message Id : \(userInfo["gcm_message_id"]!)")
        print(userInfo)
        
    }
    //notification fail
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
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
    
    // NOTE: Need to use this when swizzling is disabled
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            
            
            //testing
            guard let myuid = FIRAuth.auth()?.currentUser?.uid else { return }
            let ref = FIRDatabase.database().reference().child("user_profile").child(myuid).child("firebaseToken")
            ref.setValue(refreshedToken)
        }
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    
    func sendPush(message: String, toUserId: String) {
        let ref = FIRDatabase.database().reference().child("user_profile").child(toUserId).child("firebaseToken")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let receiverDeviceID = snapshot.value as? String {
                //acutally sending the new message nitification
                self.push(message: message, receiverToken: receiverDeviceID)
            }
        }, withCancel: nil)
        
    }
    
    //method for sending notification when user send a new message
    func push(message: String, receiverToken: String) {
        var token: String?

        token = receiverToken

        if token != nil {
            let SERVERKEY = "AAAAedKNrXc:APA91bEplrC02YRINUia0jUNUPmRcyFrf54otWZ9Nb-3D9s5mlsgTN8-cmRl5cEFiZHwDBqT07ISMg_ehNw8YzRfllTTEhsdUalVD95OzZVFQqKOvq2AxTukS_pOc62XldtTGcoAIU6zKDr1rC_QcDqK8b5FbKDFFw"

            var request = URLRequest(url: URL(string: "https://fcm.googleapis.com/fcm/send")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("key=\(SERVERKEY)", forHTTPHeaderField: "Authorization")
            let json = [
                "to" : token!,
                "priority" : "high",
                "notification" : [
                    "body" : message
                ]
                ] as [String : Any]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                request.httpBody = jsonData
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        // check for http errors
                        print("Status Code should be 200, but is \(httpStatus.statusCode)")
                        print("Response = \(response)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(responseString)")
                }
                task.resume()
            }
            catch {
                print(error)
            }
        }
    }//end push


}

