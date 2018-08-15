//
//  FlickrPhoto.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation

struct FlickrPhotos: Codable{
    let photos: FlickrPhoto
}
struct FlickrPhoto: Codable {
    let photo: [Photo]
}
struct Photo: Codable {
    let id: String
    let farm: Int
    let secret: String
    let server: String
    let height_m: String
    let width_m: String
    
    var photoUrl: NSURL {
        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
    }
}

