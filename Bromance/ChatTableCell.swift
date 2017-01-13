//
//  ChatTableCell.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/4/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import Firebase

class ChatTableCell: UITableViewCell {
    
    @IBOutlet var username: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var lastText: UILabel!
    @IBOutlet var dateSent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateSent.textColor = UIColor.gray
        lastText.textColor = UIColor.gray
    }
    
    //parse message into readable text and date
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            lastText?.text = message?.text
            //format timestamp
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                dateSent.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    //get the chatpartner using the partner's id from message
    fileprivate func setupNameAndProfileImage() {
        // *** slow rerieve data, but able save memory ***
        if let id = message?.chatPartnerId() {
            observeHelper.loadUserProfileUsingCache(thisUid: id) { (userprofile, error) in
                if error != nil {
                    print("Error: \(error!)")
                } else {
                    self.username.text = userprofile?.username?.components(separatedBy: " ")[0]
                    self.profilePic.loadImageUsingCache(urlString: (userprofile?.profile_pic_small!)!)
                }
            }
        }//end if
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
}

        
        
        
