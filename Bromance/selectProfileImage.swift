//
//  EditProfileImage.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/17/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

extension EditProfileTableVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectProfileImageVie() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedPhotoFromPicker: UIImage?
        
        if let selectEditiedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedPhotoFromPicker = selectEditiedPhoto
        } else if let selectedOriginPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedPhotoFromPicker = selectedOriginPhoto
        }
        
        if let selectedPhoto = selectedPhotoFromPicker {
            dismiss(animated: true, completion: nil)
            animateActivityIndicator()
            self.profileImage.image = selectedPhoto         //display the image
            self.updateProfileWithPhoto(image: selectedPhoto)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    func updateProfileWithPhoto(image: UIImage) {
        //firebase storage to store media files
        let storageRef = FIRStorage.storage().reference(forURL: "gs://bromance-e91d8.appspot.com")
        let profilePicRef = storageRef.child((user?.uid)! + "/profile_pic_small.jpg")
        
        let imageData = UIImageJPEGRepresentation(image, 0) //compress image to lower quality, save stoage size
        profilePicRef.put(imageData! as Data, metadata: nil, completion: {  //upload profile image into firebase
            (metadata,error) in
            
            if error != nil {
                print(error!)
                return
            }
            //download image url from storage
            let downloadUrl = metadata!.downloadURL
            let thisref = FIRDatabase.database().reference().child("user_profile").child((self.user?.uid)!).child("profile_pic_small")
            thisref.setValue(downloadUrl()!.absoluteString) //upload image url to database
            self.myActivityIndicator.stopAnimating()    //stop animating when finished uploading
            self.view.alpha = 1
        })
    }
    
    func animateActivityIndicator() {
        self.myActivityIndicator.center = self.view.center
        self.myActivityIndicator.hidesWhenStopped = true
        self.myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.myActivityIndicator.color = UIColor.red
        self.view.alpha = 0.8
        self.view.addSubview(myActivityIndicator)
        myActivityIndicator.startAnimating()
    }
    
}




