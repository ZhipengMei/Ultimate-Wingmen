//
//  EditProfileImage.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/17/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit

extension EditProfileTableVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectProfileImageVie() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.profileImage.image = selectedPhoto
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
}

