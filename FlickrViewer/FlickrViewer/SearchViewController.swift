//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var photos: [Photo] = []
    var userId: String? = nil
    private let flickrApiKey = "1ebbbfd26e664bd73f3dd4f88153e6e3"
    
    //MARK- Search
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flickrPhotoSearching(searchText: searchBar.text!)
        
    }
    
    private func flickrPhotoSearching (searchText: String){
        let escapedSearchText: String = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let requestUrl: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrApiKey)&tags=\(escapedSearchText)&per_page=50&format=json&nojsoncallback=1"
        Alamofire.request(requestUrl).responseJSON{response in
            guard let photoData = response.data else{return}
                let flickrPhotos = try? JSONDecoder().decode(FlickrPhotos.self, from: photoData)
                self.photos = (flickrPhotos?.photos.photo)!
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2),execute:{
            dump(self.photos)
            self.collectionView.reloadData()
    })
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    // MARK: UICollectionViewDataSource
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    //override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionV)
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = mainStoryboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        photoViewController.flickrPhoto = photos[indexPath.row]
        //commentsLoading(photoId: photos[indexPath.row].id)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),execute:{ //Correct that loading
            //photoViewController.comments = self.photoComments
            self.navigationController?.pushViewController(photoViewController, animated: true)})}
}
