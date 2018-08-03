//
//  ProfileViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 16/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import SDWebImage
import Alamofire

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userpic: UIImageView!
    
    var userInfo: User?
    var userId: String?
    private let flickrApiKey = "1ebbbfd26e664bd73f3dd4f88153e6e3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserpic()
        guard userId != nil else{return}
        self.userProfileRequest(userId: userId!)
    }
    
    func setUserpic(){
        let url = NSURL(string: "https://farm1.staticflickr.com/922/buddyicons/131138796@N08.jpg")
        userpic.sd_setImage(with: url as URL?)
    }
    
    private func userProfileRequest(userId: String) {
        let requestUrl: String = "https://api.flickr.com/services/rest/?method=flickr.profile.getProfile&api_key=\(flickrApiKey)&user_id=\(userId)&format=json&nojsoncallback=1"
        Alamofire.request(requestUrl).responseJSON{response in
            guard response.data != nil else{return}
        let profile = try! JSONDecoder().decode(User.self, from: response.data!)
            self.userInfo = profile
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show User Info" {
            let profileInfoViewController = segue.destination as! ProfileInfoViewController
            profileInfoViewController.userInfo = userInfo
        }
    }
}
