//
//  User.swift
//  Bromance
//
//  Created by Zhipeng Mei on 1/10/17.
//  Copyright © 2017 Team Grit. All rights reserved.
//

import UIKit

class User: NSObject {
    var username : String?
    var email: String?
    var age: String?
    var gender: String?
    var profile_pic_small: String?
    var website: String?
    var years_in_game: String?
    var connections: NSDictionary?
    var level: String?
    var firebaseToken: String?
    var blocked: NSDictionary?
    
    // 自定义构造函数,会覆盖init()函数
    init(dict : [String : NSObject]) {
        // 必须先初始化对象
        super.init()
        
        // 调用对象的KVC方法字典转模型
        setValuesForKeys(dict)
    }
}
