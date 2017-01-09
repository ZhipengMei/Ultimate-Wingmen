//
//  ChatTableCell.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/4/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit

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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
