//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import Alamofire
import hkAlium
import collection_view_layouts
import GreedoLayout

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    private var photos: [Photo] = []
    //private var cellSizes: [CGSize] = []
    private var fetchingMore = false
    private var currentPage = 1
    private var flowLayout: ContentDynamicLayout = FlickrStyleFlowLayout()    //MARK- Search
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshRecentFlickrPhotos), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.flowLayout.delegate = self
        self.flowLayout.contentPadding = ItemsPadding(horizontal: 10, vertical: 10)
        self.flowLayout.cellsPadding = ItemsPadding(horizontal: 8, vertical: 8)
        self.flowLayout.contentAlign = .left
        collectionView.collectionViewLayout = flowLayout
//        self.flowLayout?.numberOfColumns = 2
//        self.flowLayout?.cellPadding = 2
        collectionView.refreshControl = refresher
        getRecentFlickrPhotos(pageNumber:1) {
            print("Recent photos adding...")
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        activityIndicator.startAnimating()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        flickrPhotosSearch(searchText: searchBar.text!) {
            print("Search query successfull!")
            self.collectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
        activityIndicator.startAnimating()
    }
    
    @objc private func refreshRecentFlickrPhotos(){
        self.fetchingMore = true
        let requestUrl = FlickrURL()
        let pageNumber: Int = 1
        let flickrUrlString = requestUrl.baseUrl +
            requestUrl.getRecentQuery +
            requestUrl.apiKey +
            requestUrl.extras +
            requestUrl.recentPhotosPerPage +
            requestUrl.page +
            String(pageNumber) +
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
                    print("FETCHING ERROR")
                })
                error.addAction(ok)
                self?.present(error, animated: true, completion: nil)
                self?.refresher.endRefreshing()
                self?.activityIndicator.stopAnimating()
                self?.fetchingMore = false
                return
            }
            self?.photos = photoArray
            print("Recent photos refreshed")
            self?.fetchingMore = false
            self?.collectionView.reloadData()
            self?.activityIndicator.stopAnimating()
            self?.refresher.endRefreshing()
        }
    }

    private func getRecentFlickrPhotos(pageNumber: Int,completion: @escaping () -> ()){
        self.fetchingMore = true
        let requestUrl = FlickrURL()
        let pageNumber: Int = pageNumber
        let flickrUrlString = requestUrl.baseUrl +
            requestUrl.getRecentQuery +
            requestUrl.apiKey +
            requestUrl.extras +
            requestUrl.recentPhotosPerPage +
            requestUrl.page +
            String(pageNumber) +
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
                    print("FETCHING ERROR")
                })
                error.addAction(ok)
                self?.present(error, animated: true, completion: nil)
                self?.refresher.endRefreshing()
                self?.activityIndicator.stopAnimating()
                self?.fetchingMore = false
                return
            }
            self?.fetchingMore = false
            self?.photos = photoArray
            completion()
        }
    }
    
    private func flickrPhotosSearch(searchText: String, completion:  @escaping () -> ()) {
        let requestUrl = FlickrURL()
        let pageNumber: Int = 1
        let flickrUrlString = requestUrl.baseUrl +
            requestUrl.searchQuery +
            requestUrl.apiKey +
            requestUrl.searchTags +
            ("\(searchText)") +
            requestUrl.extras +
            requestUrl.sort +
            requestUrl.photosPerPage +
            requestUrl.page +
            String(pageNumber) +
            requestUrl.format
        print("\(flickrUrlString)")
        Alamofire.request(flickrUrlString).responseJSON { [weak self] response in
            guard let photoData = response.data else {
                return
            }
            let flickrPhotos = try? JSONDecoder().decode(FlickrPhotos.self, from: photoData)
            guard let photoArray = flickrPhotos?.photos.photo else {
                let error = UIAlertController(
                    title: "Error", message: "Search query unsuccessfull!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
                    print("FETCHING ERROR")
                })
                error.addAction(ok)
                self?.present(error, animated: true, completion: nil)
                self?.activityIndicator.stopAnimating()
                return
            }
            self?.photos = photoArray
            completion()
        }
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, /*CustomLayoutDelegate,*/ ContentDynamicLayoutDelegate {
    
    func cellSize(indexPath: IndexPath) -> CGSize {
        guard let photoHeight = Float(photos[indexPath.row].height_m) else {
            return CGSize(width: 0, height: 0)
                    }
        guard let photoWidth = Float(photos[indexPath.row].width_m) else {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: CGFloat(photoWidth), height: CGFloat(photoHeight))
    }
    
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore{
                self.activityIndicator.startAnimating()
                getRecentFlickrPhotos(pageNumber:currentPage+1){
                    self.currentPage += 1
                    print("one more page loaded. CURRENT PAGE IS \(self.currentPage)")
                    self.fetchingMore = false
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

//    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
//        guard let photoHeight = Float(photos[indexPath.row].height_m) else {
//            return CGFloat(0)
//        }
//            return CGFloat(photoHeight/2)
//    }
}
