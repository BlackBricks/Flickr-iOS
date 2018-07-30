//
//  BDBOUser.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 25/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit

class BDBOUser{
    
    var  dictionary:NSDictionary?
    init(dictionary:NSDictionary){
        self.dictionary = dictionary
    }
    
    static var _currentUser:BDBOUser?
    
    class var currentUser: BDBOUser? {
        get {
            if (_currentUser == nil){
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUser") as? NSData
                
                if let userData = userData{
                    let dictionary = try! JSONSerialization.jsonObject(with: userData as Data, options: []) as! NSDictionary
                    
                    _currentUser = BDBOUser(dictionary:dictionary)
                }
            }
            return _currentUser
        }
        set(user){
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey:"currentUser")
            }else{
                defaults.set(nil, forKey:"currentUser")
            }
        }
    }
}
