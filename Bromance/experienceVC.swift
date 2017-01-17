//
//  experienceVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/17/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class experienceVC: UIViewController {

    @IBOutlet var expTextField: UITextField!
    @IBOutlet var doneBtn: UIButton!
    @IBOutlet var expView: UIView!
    
    var ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add tapgesture to dissmiss view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
        
        expTextField.becomeFirstResponder()
        
        doneBtn.isHidden = true
        self.expView.layer.cornerRadius = 5
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAnimate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.view.endEditing(true)
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
    

    @IBAction func textChanged(_ sender: Any) {
        doneBtn.isHidden = false
        checkMaxLength(textField: expTextField, maxLength: 2)
    }

    @IBAction func updateExp(_ sender: Any) {
        self.ref.child("user_profile").child("\(user!.uid)/years_in_game").setValue(expTextField.text)
        removeAnimate()
    }

}
