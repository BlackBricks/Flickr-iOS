//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import OAuthSwift
import SafariServices

class SearchViewController:UIViewController, UISearchControllerDelegate,UISearchBarDelegate {
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func authorize(_ sender: UIButton) {
//        let url = URL(string: "https://www.flickr.com/services/oauth/request_token?oauth_nonce=95613465&oauth_timestamp=1305586162&oauth_consumer_key=1ebbbfd26e664bd73f3dd4f88153e6e3&oauth_signature_method=HMAC-SHA1&oauth_version=1.0&oauth_signature=7w18YS2bONDPL%2FzgyzP5XTr5af4%3D&oauth_callback=http%3A%2F%2Fwww.example.com")
//        let safariVC = SFSafariViewController(url: url!)
//        present(safariVC, animated: true, completion: nil)
        //testFlickr(flickrAuth, consumerKey: "1ebbbfd26e664bd73f3dd4f88153e6e3")
        
        let handle = flickrAuth.authorize(
            withCallbackURL: URL(string: "flickrviewer://oauth-callback/flickr")!,
                success: { credential, response, parameters in
                    print(credential.oauthToken)
                    print(credential.oauthTokenSecret)
                    print(parameters["user_id"])
            },
                failure: { error in
                    print(error.localizedDescription)
            }
            )
    }
    
    let flickrAuth = OAuth1Swift(
        consumerKey: "1ebbbfd26e664bd73f3dd4f88153e6e3",
        consumerSecret: "10d4d671ddf8546a",
        requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
        authorizeUrl: "https://www.flickr.com/services/oauth/authorize",
        accessTokenUrl: "https://www.flickr.com/services/oauth/access_token"
    )
    
//    let handle = flickrAuth.authorize(
//        withCallbackURL: URL(string: "flickrviewer")!,
//        success: { credential, response, parameters in
//            print(credential.oauthToken)
//            print(credential.oauthTokenSecret)
//            print(parameters["user_id"])
//    },
//        failure: { error in
//            print(error.localizedDescription)
//    }
//    )
    
    func testFlickr (_ oauthswift: OAuth1Swift, consumerKey: String) {
        let url :String = "https://api.flickr.com/services/rest/"
        let parameters :Dictionary = [
            "method"         : "flickr.photos.getRecent",
            "api_key"        : consumerKey,
            "user_id"        : "159293991@N05",
            "format"         : "json",
            "nojsoncallback" : "1",
            "extras"         : "url_q,url_z"
        ]
        let _ = oauthswift.client.get(
            url, parameters: parameters,
            success: { response in
                let jsonDict = try? response.jsonObject()
                print(jsonDict as Any)
        },
            failure: { error in
                print(error)
        }
        )
    }
    var photos: [FlickrPhoto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performRequest(searchText: searchBar.text!)
        //if !photos.isEmpty {
            //performSegue(withIdentifier: "ShowPhotoCollection", sender: self)//}
    }
    
    private func performRequest(searchText: String) {
        print("START SEARCHING")
        FlickrPopularRequest.fetchPhotosForRequest(searchText: searchText, onCompletion: { (error: NSError?, flickrPhotos: [FlickrPhoto]?) -> Void in
            if error == nil {
                self.photos = flickrPhotos!
                print("PHOTOS ARE LOADED")
                
            } else {
                self.photos = []
                if (error!.code == FlickrPopularRequest.Errors.invalidAccessErrorCode) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.showErrorAlert()
                    })
                }
            }
            DispatchQueue.main.async(execute: { () -> Void in
                //self.title = searchText
                //self.reloadData()
                self.performSegue(withIdentifier: "ShowPhotoCollection", sender: self)
            })
        })
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ShowPhotoCollection" {
                
            let imageCollectionViewController = segue.destination as! ImageCollectionViewController
            imageCollectionViewController.photos = photos
        }
        if segue.identifier == "Profile"{
            let profileViewController = segue.destination as! ProfileViewController
        }
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Search Error", message: "Invalid API Key", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
