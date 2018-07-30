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
    
    
    
    var userInfo:User?
    var userId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserpic()
        self.performRequest()
    }
    func setUserpic(){
        let url = NSURL(string: "https://farm1.staticflickr.com/922/buddyicons/131138796@N08.jpg")
        userpic.sd_setImage(with: url as URL?)
    }
    
    
    private func performRequest() {
        FlickrProfileRequest.fetchProfileForRequest(userId: userId!, onCompletion: {(error: NSError?, userInfo:User?) -> Void in
            if error == nil {
                self.userInfo = userInfo!
                print("INFO IS LOADED")
                
            } else {
                self.userInfo = nil
                if (error!.code == FlickrSearchRequest.Errors.invalidAccessErrorCode) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                    })
                }
            }
            DispatchQueue.main.async(execute: { () -> Void in
                
            })
        })
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show User Info" {
            let profileInfoViewController = segue.destination as! ProfileInfoViewController
profileInfoViewController.userInfo = userInfo
        }
    }
}
