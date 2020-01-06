//
//  FlickrPhoto.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation
import UIKit

struct FlickrPhotos: Codable {
    let photos: FlickrPhoto
}

struct FlickrPhoto: Codable {
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let farm: Int
    let iconfarm: Int
    let secret: String
    let server: String
    let iconserver: String
    let height_m: Int
    let width_m: Int
    let title: String
    let ownername: String
    let owner: String
    let views: String
    let url_c: String
    let url_m: String
    let url_s: String
    let url_n: String
    let url_t: String
    
    var photoUrl: NSURL {
        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
    }
    
    var avatarURL: NSURL {
        return NSURL(string:"http://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(owner).jpg")!
    }
    
    
    
    func isPhotoSizeValid() -> Bool {
//        guard let _ = Int(width_m) else {
//                return false
//        }
        return true
    }
    
    func size() -> CGSize {
//        guard
//            let width = Int(width_m) else {
//                return CGSize.zero
//        }
        return CGSize(width: width_m, height: height_m)
    }
}



