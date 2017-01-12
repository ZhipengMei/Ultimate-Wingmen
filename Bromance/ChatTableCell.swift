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
        if let id = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("user_profile").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in //observe would terminate once it finished running
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.username.text = dictionary["username"] as? String
                    //display profile image using cache method
                    if let profileImageUrl = dictionary["profile_pic_small"] as? String {
                        self.profilePic.loadImageUsingCache(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
