//
//  levelPicker.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/17/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class levelPicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var pickerView: UIPickerView!
    var ref = FIRDatabase.database().reference()
    let user = FIRAuth.auth()?.currentUser
    
    var levels = ["AFC","Shotgun","Rapport","Instant Date","Date 2","Pull Sometime","Monthly Pull","Weekly Pull","3s", "savage af", "Got em' coach"]
    var level: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self

        //add tapgesture to dissmiss view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    
        self.pickerView.layer.cornerRadius = 5
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        showAnimate()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return levels.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return levels[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        level = levels[row]
    }

    @IBAction func updateLevel(_ sender: Any) {
        self.ref.child("user_profile").child("\(user!.uid)/level").setValue(level!)
        removeAnimate()
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
}
