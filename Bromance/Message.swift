//
//  Messages.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/11/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var receiverId: String?
    var senderId: String?
    var senderName: String?
    var text: String?
    var timestamp: NSNumber?
    var mediaURL: String?
    
    // 自定义构造函数,会覆盖init()函数
    init(dict : [String : NSObject]) {
        // 必须先初始化对象
        super.init()
        
        // 调用对象的KVC方法字典转模型
        setValuesForKeys(dict)
    }
    
    func chatPartnerId() -> String? {
        return receiverId == FIRAuth.auth()?.currentUser?.uid ? senderId : receiverId
    }
}
