//
//  NearbyUsersCollectionCell.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/28/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit

class NearbyUsersCollectionCell: UICollectionViewCell {
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    
    //overriding the user image to make it circular
    override func layoutSubviews() {
        super.layoutSubviews()
        self.makeItRound()
    }
    
    func makeItRound() {
        self.userImage.layer.masksToBounds = true
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2.0
    }
    
}
