//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var photos: [Photo] = []
    var userId: String? = nil
    private let flickrApiKey = "1ebbbfd26e664bd73f3dd4f88153e6e3"
    
    
    //MARK- Search
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flickrPhotoSearching(searchText: searchBar.text!)//make throwable
        
        
    }
    
    private func flickrPhotoSearching (searchText: String) {
        let escapedSearchText: String = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let requestUrl: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrApiKey)&tags=\(escapedSearchText)&extras=url_o,url_m,owner_name,date_upload,views,icon_server&sort=relevance&per_page=50&format=json&nojsoncallback=1"
        
        Alamofire.request(requestUrl).responseJSON{response in
            guard let photoData = response.data else{return}
            let flickrPhotos = try! JSONDecoder().decode(FlickrPhotos.self, from: photoData)
            print(flickrPhotos)
            self.photos = (flickrPhotos.photos.photo)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2),execute:{
            self.collectionView.reloadData()
        })
    }
    
    
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    // MARK: UICollectionViewDataSource
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let photoHeight = Float(photos[indexPath.row].height_m) else {return CGSize(width: 0.0, height: 0.0)}
        guard let photoWidth = Float(photos[indexPath.row].width_m) else {return CGSize(width: 0.0, height: 0.0)}
        let aspectRatio = (photoHeight/photoWidth)
        if let height = flowLayout?.itemSize.height{
            return CGSize(width: height/CGFloat(aspectRatio), height: height)
        }
        return CGSize(width: 0.0, height: 0.0)
    }
}
