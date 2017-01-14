//
//  Extensions.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/9/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCache(urlString: String) {
        //reset the image at the beginning
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            //print("inside cachedimage")
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        //url request
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        
        //download the image
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in

            if error != nil {
                print(error!)
                return
            }
            
            // Move to a background thread to do some long running work
            DispatchQueue.global(qos: .userInitiated).async {
                // Bounce back to the main thread to update the UI
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!) {
                        //print("inside download image")
                        imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                        self.image = downloadedImage
                    }
                }
            }//end DispatchQueue

        }//end task
        task.resume()
        
    }//end loadimage function
    
    
}
