//
//  FlickrPhotoSizes.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/08/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation

struct FlickrPhotosSizes: Codable {
    let sizes: FlickrPhotosSize
}
struct FlickrPhotosSize: Codable {
    let size: [Size]
}
struct Size: Codable {
    let label: String
    let source: URL
}
