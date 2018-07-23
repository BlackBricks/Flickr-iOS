//
//  FlickrProfileRequest.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 18/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation

class FlickrProfileRequest {
    typealias FlickrResponse = (NSError?, User?) -> Void
    
    struct Keys {
        static let flickrKey = "1ebbbfd26e664bd73f3dd4f88153e6e3"
    }
    
    struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    class func fetchProfileForRequest( userId: String, onCompletion: @escaping FlickrResponse) -> Void {
        print("START FETCHING PROFILE")
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.profile.getProfile&api_key=161b5915bd1fda98d63f4433d8eb3118&user_id=144273526%40N06&format=json&nojsoncallback=1"
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
                print("\(resultsDictionary)")
                let jsonData = """
{ "profile": { "id": "144273526@N06", "nsid": "144273526@N06", "join_date": "1476788143", "occupation": "", "hometown": "", "showcase_set": "72157677437432183", "showcase_set_title": "Profile Showcase", "first_name": "Inka", "last_name": "Sinclair", "profile_description": "", "city": "", "country": "", "facebook": "", "twitter": "", "tumblr": "", "instagram": "", "pinterest": "" }, "stat": "ok" }
""".data(using: .utf8)!
                
                let profile = try! JSONDecoder().decode(User.self, from: jsonData)
                dump(profile)
                  
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
