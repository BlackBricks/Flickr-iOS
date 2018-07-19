//
//  ProfileViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 16/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//
import Foundation
import UIKit
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var userpic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserpic()
    }
    func setUserpic(){
        let url = NSURL(string: "https://farm2.staticflickr.com/1767/42538632735_8a72cb797a_m.jpg")
        userpic.sd_setImage(with: url as URL?)
        
        
    }
}
