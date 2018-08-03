//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var photoArray: [Photo] = []
    var userId: String? = nil
    private let flickrApiKey = "1ebbbfd26e664bd73f3dd4f88153e6e3"
    
    //MARK- Search
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flickrPhotoSearching(searchText: searchBar.text!)
    }
    
    private func flickrPhotoSearching (searchText: String){
        let escapedSearchText: String = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let requestUrl: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrApiKey)&tags=\(escapedSearchText)&per_page=50&format=json&nojsoncallback=1"
        Alamofire.request(requestUrl).responseJSON{response in
            guard response.data != nil else{return}
                let flickrPhotos = try? JSONDecoder().decode(FlickrPhotos.self, from: response.data!)
                self.photoArray = (flickrPhotos?.photos.photo)!
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2),execute:{
            self.performSegue(withIdentifier: "ShowPhotoCollection", sender: self)})
    }
    
    //MARK - Authorization
    @IBAction func authorize(_ sender: UIButton) {
        let _ = flickrAuth.authorize(
            withCallbackURL: URL(string: "flickrviewer://oauth-callback/flickr")!,
            success: { credential, response, parameters in
                print("oauthToken:\(credential.oauthToken)")
                print("oauthTokeSecret:\(credential.oauthTokenSecret)")
                print("user_nsID: \(parameters["user_nsid"]!)")
                self.userId = (parameters["user_nsid"] as! String)
                self.performSegue(withIdentifier: "Profile", sender: self)
        },
            failure: {
                error in
                print(error.localizedDescription)
        })}
    
    let flickrAuth = OAuth1Swift(
        consumerKey: "1ebbbfd26e664bd73f3dd4f88153e6e3",
        consumerSecret: "10d4d671ddf8546a",
        requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
        authorizeUrl: "https://www.flickr.com/services/oauth/authorize",
        accessTokenUrl: "https://www.flickr.com/services/oauth/access_token"
    )
    
    private func testFlickr (_ oauthswift: OAuth1Swift, consumerKey: String) {
        let url :String = "https://api.flickr.com/services/rest/"
        let parameters :Dictionary = [
            "method"         : "flickr.auth.oauth.getAccessToken",
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
        })}
    
    //MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoCollection" {
            let imageCollectionViewController = segue.destination as! ImageCollectionViewController
            imageCollectionViewController.photos = photoArray
        }
        if segue.identifier == "Profile"{
            let profileViewController = segue.destination as! ProfileViewController
            profileViewController.userId = userId
        }
    }
}
