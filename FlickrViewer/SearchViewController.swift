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
    
    private var photos: [Photo] = []
    
    //MARK- Search
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        getRecentFlickrPhotos {
            print("Recent photos adding...")
            self.collectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flickrPhotosSearch(searchText: searchBar.text!) {
            print("Search query successfull!")
            self.collectionView.reloadData()
        }
    }
    
    private func getRecentFlickrPhotos(completion: @escaping () -> ()){
        let requestUrl = FlickrURL()
        let flickrUrlString = requestUrl.baseUrl +
            requestUrl.getRecentQuery +
            requestUrl.apiKey +
            requestUrl.extras +
            requestUrl.recentPhotosPerPage +
            requestUrl.format
        print("\(flickrUrlString)")
        Alamofire.request(flickrUrlString).responseJSON { [weak self] response in
            guard let photoData = response.data else {
                return
            }
            let flickrPhotos = try? JSONDecoder().decode(FlickrPhotos.self, from: photoData)
            guard let photoArray = flickrPhotos?.photos.photo else {
                let error = UIAlertController(
                title: "Error", message: "Recent photos not set", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
                    print("Ok button tapped")
                })
                error.addAction(ok)
                self?.present(error, animated: true, completion: nil)
                return
            }
            self?.photos = photoArray
            completion()
        }
    }
    
    private func flickrPhotosSearch(searchText: String, completion:  @escaping () -> ()) {
        let requestUrl = FlickrURL()
        let flickrUrlString = requestUrl.baseUrl +
            requestUrl.searchQuery +
            requestUrl.apiKey +
            requestUrl.searchTags +
            ("\(searchText)") +
            requestUrl.extras +
            requestUrl.sort +
            requestUrl.photosPerPage +
            requestUrl.format
        Alamofire.request(flickrUrlString).responseJSON { [weak self] response in
            guard let photoData = response.data else {
                return
            }
            let flickrPhotos = try? JSONDecoder().decode(FlickrPhotos.self, from: photoData)
            guard let photoArray = flickrPhotos?.photos.photo else {
                let error = UIAlertController(
                    title: "Error", message: "Search query unsuccessfull!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
                    print("Ok button tapped")
                })
                error.addAction(ok)
                self?.present(error, animated: true, completion: nil)
                return
            }
            self?.photos = photoArray
            completion()
        }
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    private var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photoHeight = Float(photos[indexPath.row].height_m) else {
            return CGSize(width: 0.0, height: 0.0)
        }
        guard let photoWidth = Float(photos[indexPath.row].width_m) else {
            return CGSize(width: 0.0, height: 0.0)
        }
        let aspectRatio = (photoWidth / photoHeight)
        if let width = flowLayout?.itemSize.width {
            return CGSize(width: width, height: width / CGFloat(aspectRatio))
        }
        return CGSize(width: 0.0, height: 0.0)
    }
}
