//
//  FlickrProfileRequest.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 18/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation

class FlickrProfileRequest {
    typealias FlickrResponse = (NSError?, [User]?) -> Void
    
    struct Keys {
        static let flickrKey = "1ebbbfd26e664bd73f3dd4f88153e6e3"
    }
    
    struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    class func fetchProfileForRequest( userId: String, onCompletion: @escaping FlickrResponse) -> Void {
        print("START FETCHING PROFILE")
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.profile.getProfile&api_key=0ebf995fbfc3b59157e96d5f1bf94cd5&user_id=144273526%40N06&format=json&nojsoncallback=1"
        let url: NSURL = NSURL(string: urlString)!
        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            if error != nil {
                print("Error fetching profile: \(error ?? 0 as! Error)")
                onCompletion(error as NSError?, nil)
                return
            }
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == Errors.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        onCompletion(invalidAccessError, nil)
                        return
                    }
                }
                
                guard let profileContainer = resultsDictionary!["profile"] as? NSDictionary else { return }
                guard let profileArray = profileContainer["profile"] as? [NSDictionary] else { return }
                print ("\(profileArray)")
                let profile: [User] = profileArray.map { profileDictionary in
                    
                    let firstName = profileDictionary["first_name"] as? String ?? ""
                    let lastName = profileDictionary["last_name"] as? String ?? ""
                    let country = profileDictionary["country"] as? String ?? ""
                    let city = profileDictionary["city"] as? String ?? ""
                    let description = profileDictionary["description"] as? String ?? ""
                    
                    let profile = User( firstName: firstName, lastName: lastName, country: country, city: city, description: description)
                    
                    return profile
                }
                
                onCompletion(nil, profile)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(error, nil)
                return
            }
            
        })
        searchTask.resume()
    }
    
    
    
}
