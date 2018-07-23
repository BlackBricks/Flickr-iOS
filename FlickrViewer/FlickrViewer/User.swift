//
//  User.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 13/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation
import UIKit

struct User:Codable {
    var profile: Profile
}
struct Profile:Codable {
    let first_name: String
    let last_name: String
}


