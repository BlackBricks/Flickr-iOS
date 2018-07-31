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
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.profile.getProfile&api_key=1ebbbfd26e664bd73f3dd4f88153e6e3&user_id=\(userId)&format=json&nojsoncallback=1"
        let url: NSURL = NSURL(string: urlString)!
        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            if error != nil {
                print("Error fetching profile: \(error ?? 0 as! Error)")
                onCompletion(error as NSError?, nil)
                return
            }
            do { print("\(String(describing: data))")
//                
                let profile = try! JSONDecoder().decode(User.self, from: data!)
                dump(profile)
                  
                onCompletion(nil, profile)
                
            }
//            catch let error as NSError {
//                print("Error parsing JSON: \(error)")
//                onCompletion(error, nil)
//                return
//            }
        })
        searchTask.resume()
    }
    
    
    
}
