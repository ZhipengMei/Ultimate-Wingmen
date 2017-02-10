//
//  genderPopupView.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/17/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class genderPopupView: UIViewController {
    
    @IBOutlet var genderView: UIView!
    
    var ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add tapgesture to dissmiss view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)

        self.genderView.layer.cornerRadius = 10
        self.genderView.layer.masksToBounds = true
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAnimate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // *** gender ***
    func showAnimate() {
        self.view.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }
    }
    
    func removeAnimate() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.view.alpha = 0
        }) {(success: Bool) in
            self.view.removeFromSuperview()
        }
    }
    @IBAction func man(_ sender: Any) {
        self.ref.child("user_profile").child("\(user!.uid)/gender").setValue("Man")
        removeAnimate()
    }
    @IBAction func woman(_ sender: Any) {
        self.ref.child("user_profile").child("\(user!.uid)/gender").setValue("Woman")
        removeAnimate()
    }
    // *** gender end ***
    


}
