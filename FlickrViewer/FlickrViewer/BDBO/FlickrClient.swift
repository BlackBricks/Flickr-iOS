//
//  FlickrClient.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 25/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SafariServices

class FlickrClient:BDBOAuth1SessionManager {
    
    static let sharedInstance = FlickrClient(baseURL: NSURL(string: "https://www.flickr.com/services")! as URL, consumerKey: "1ebbbfd26e664bd73f3dd4f88153e6e3", consumerSecret: "10d4d671ddf8546a")
    
    var loginSuccess: (()->())?
    var loginFailure: ((NSError)->())?
    
    weak var delegate: FlickrLoginDelegate?
    //Getting request token
    func login(success: @escaping ()->(),failure:@escaping (NSError)->())
    {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        
        fetchRequestToken(withPath: "/oauth/request_token", method: "GET", callbackURL: NSURL(string: "flickrviewer://oauth-callback/flickr")! as URL, scope: nil, success: {(requestToken) in
            print("Got token")
            let url = NSURL(string: "https://www.flickr.com/services/oauth/authorize?oauth_token=" + (requestToken?.token)!)!
            
            if #available(iOS 10.0, *){
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)}else{
                UIApplication.shared.openURL(url as URL)
            }
}){(error) in
            print("error:\(error?.localizedDescription ?? "")")
            self.loginFailure?(error! as NSError)
        }
    }
    
    func handleOpen(url:NSURL){

        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "/oauth/access_token", method: "POST", requestToken: requestToken, success: {(accessToken) in
            self.currentAccount(success: {(user:BDBOUser) in
                BDBOUser.currentUser = user
                self.loginSuccess?()
                self.delegate?.continueLogin()
            }, failure: {(error) in
                self.loginFailure?(error)
            })
            self.loginSuccess?()
        }){(error) in
            print("error:\(error?.localizedDescription ?? "")")
            self.loginFailure?(error! as NSError)
        }
    }
    func currentAccount(success:(BDBOUser) ->(),failure:(NSError) ->()){
    }
}
