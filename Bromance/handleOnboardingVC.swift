//
//  handleOnboardingVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/18/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import PaperOnboarding

class handleOnboardingVC: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    @IBOutlet var onboardView: onboardingViewController!
    @IBOutlet var getsartedBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        onboardView.dataSource = self
        onboardView.delegate = self
        self.getsartedBtn.alpha = 0
    }
    
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroundColorOne = UIColor(red: 217/255, green: 72/255, blue: 89/255, alpha: 1)
        let backgroundColorTwo = UIColor(red: 106/255, green: 166/255, blue: 211/255, alpha: 1)
        let backgroundColorThree = UIColor(red: 168/255, green: 200/255, blue: 78/255, alpha: 1)
        
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-regular", size: 18)!
        
        return [("map", "Find Local Wings", "Meet new people \n whenever \n wherever", "", backgroundColorOne, UIColor.white, UIColor.white, titleFont, descriptionFont),
                
                ("chat", "Make a Plan", "Wine tasting, hit the gym, grab a drink, do whatever you want...", "", backgroundColorTwo, UIColor.white, UIColor.white, titleFont, descriptionFont),
                
                ("joystick", "Game On", "Everyday is a good day to game.", "", backgroundColorThree, UIColor.white, UIColor.white, titleFont, descriptionFont)][index]
    }
    
    
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
    }

    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 1 {
            if self.getsartedBtn.alpha == 1 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.getsartedBtn.alpha = 0
                })
            }//end if
        }//end if
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2 {
            UIView.animate(withDuration: 0.4, animations: {
                self.getsartedBtn.alpha = 1
            })
        }
    }

    @IBAction func gotStarted(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        //notify onboarding screen already completed
        userDefaults.set(true, forKey: "onboardingComplete")
        userDefaults.synchronize()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
