//
//  AsyncPhotoMediaItem.swift
//  Bromance
//
//  Created by Zhipeng Mei on 2/4/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Kingfisher


class AsyncPhotoMediaItem: JSQPhotoMediaItem {
    var asyncImageView: UIImageView!
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    init(withURL url: NSURL) {
        super.init()
        asyncImageView = UIImageView()
        asyncImageView.frame = CGRect(0, 0, 170, 130)
        asyncImageView.contentMode = .scaleAspectFill
        asyncImageView.clipsToBounds = true
        asyncImageView.layer.cornerRadius = 20
        asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        
        let activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
        activityIndicator?.frame = asyncImageView.frame
        asyncImageView.addSubview(activityIndicator!)
        
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString!, options: nil) { (image, cacheType) -> () in
            
            if let image = image {
                self.asyncImageView.image = image
                activityIndicator?.removeFromSuperview()
            } else {
                KingfisherManager.shared.downloader.downloadImage(with:
                url as URL, progressBlock: nil) { (image, error, imageURL, originalData) -> () in
                    
                    if let image = image {
                        self.asyncImageView.image = image
                        activityIndicator?.removeFromSuperview()
                        
                        KingfisherManager.shared.cache.store(image, forKey: url.absoluteString!, toDisk: true, completionHandler: nil)
                    }
                }
            }
        }
    }

    override func mediaView() -> UIView! {
        return asyncImageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return asyncImageView.frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
