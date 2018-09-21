//
//  FlickrURL.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 16/08/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation

struct FlickrURL {
    let baseUrl = "https://api.flickr.com/services/rest/"
    let searchQuery = "?method=flickr.photos.search"
    let getRecentQuery = "?method=flickr.photos.getRecent"
    let popularPhotosQuery = "?method=flickr.interestingness.getList"
    let apiKey = "&api_key=1ebbbfd26e664bd73f3dd4f88153e6e3"
    let searchTags = "&tags="
    let extras = "&extras=url_c,url_m,url_s,url_n,url_t,owner_name,date_upload,views,icon_server"
    let sort = "&sort=relevance"
    let photosPerPage = "&per_page=20"
    let recentPhotosPerPage = "&per_page=50"
    let page = "&page="
    let format = "&format=json&nojsoncallback=1"
}
