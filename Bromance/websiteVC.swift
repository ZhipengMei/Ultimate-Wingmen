//
//  websiteVC.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/17/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class websiteVC: UIViewController {

    @IBOutlet var webTextField: UITextField!
    @IBOutlet var websiteView: UIView!
    @IBOutlet var doneBtn: UIButton!
    
    var ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //add tapgesture to dissmiss view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
        
        webTextField.becomeFirstResponder()
        
        doneBtn.isHidden = true
        self.websiteView.layer.cornerRadius = 10
        self.websiteView.layer.masksToBounds = true
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
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform.init(scaleX: 1.3, y:1.3)
            self.view.alpha = 0
        }) {(success: Bool) in
            self.view.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editingWebText(_ sender: Any) {
        doneBtn.isHidden = false
    }

    @IBAction func updateWebsite(_ sender: Any) {
        self.ref.child("user_profile").child("\(user!.uid)/website").setValue(webTextField.text)
        removeAnimate()
    }

   

}
