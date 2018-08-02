//
//  ProfileInfoViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 20/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit

class ProfileInfoViewController: UIViewController {
    
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    
    var userInfo:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.text = userInfo?.profile.first_name
        lastName.text = userInfo?.profile.last_name
    }
}
