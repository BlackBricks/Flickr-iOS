//
//  Commentary.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 13/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//


struct FlickrComments: Codable {
    let comments: CommentsArray
}
struct CommentsArray: Codable {
    let comment:[Comment]
}
struct Comment: Codable {
    let authorname: String
    let _content: String
}
