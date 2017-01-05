//
//  TextInputCell.swift
//  Bromance
//
//  Created by Zhipeng Mei on 12/27/16.
//  Copyright © 2016 Team Grit. All rights reserved.
//

import UIKit

class TextInputCell: UITableViewCell {

    @IBOutlet var myTextField: UITextField!
    @IBOutlet var myLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(text:String?, placeholder:String?, labelText:String?) {
        myTextField.text = text
        myTextField.placeholder = placeholder
        myLabel.text = labelText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
