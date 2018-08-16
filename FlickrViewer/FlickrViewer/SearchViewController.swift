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
    
    //MARK- Search
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flickrPhotoSearching(searchText: searchBar.text!)//make throwable
    }
    
    
    private func flickrPhotoSearching (searchText: String) {
        let escapedSearchText: String = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let requestUrl = FlickrURL()
        let urlString = requestUrl.baseUrl+requestUrl.method+requestUrl.apiKey+requestUrl.searchTags+("\(escapedSearchText)")+requestUrl.extras+requestUrl.sort+requestUrl.photosPerPage+requestUrl.format
        Alamofire.request(urlString).responseJSON{response in
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let photoHeight = Float(photos[indexPath.row].height_m) else {return CGSize(width: 0.0, height: 0.0)}
        guard let photoWidth = Float(photos[indexPath.row].width_m) else {return CGSize(width: 0.0, height: 0.0)}
        let aspectRatio = (photoWidth/photoHeight)
        
        
        
        if let width = flowLayout?.itemSize.width{
            return CGSize(width: width, height: width/CGFloat(aspectRatio))
        }
        
        return CGSize(width: 0.0, height: 0.0)
    }
}
