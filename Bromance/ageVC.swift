//
//  ageVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/17/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ageVC: UIViewController {

    @IBOutlet var ageView: UIView!
    @IBOutlet var ageField: UITextField!
    
    @IBOutlet var doneBtn: UIButton!
    var ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneBtn.isHidden = true
        self.ageView.layer.cornerRadius = 5
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAnimate()
    }
    
    
    func showAnimate() {
        self.view.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.view.alpha = 0
        }) {(success: Bool) in
            self.view.removeFromSuperview()
        }
    }
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if ((textField.text?.characters.count)! > maxLength) {
            textField.deleteBackward()
        }
    }
    
    @IBAction func enterAge(_ sender: Any) {
        doneBtn.isHidden = false
        checkMaxLength(textField: ageField, maxLength: 2)
    }
    
    @IBAction func updateAge(_ sender: Any) {
        self.ref.child("user_profile").child("\(user!.uid)/age").setValue(ageField.text)
        self.view.endEditing(true)
        removeAnimate()
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
