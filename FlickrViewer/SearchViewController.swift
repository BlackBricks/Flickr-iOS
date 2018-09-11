//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import Alamofire
import PullToRefresh

class SearchViewController: UIViewController, UISearchBarDelegate {

    private var photos: [Photo] = []
    private var justifiedSizes: [CGSize] = []
    private var request: DataRequest? = nil
    private var currentLoadedPage = 0
    private var currentSearch: String? = nil

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var glassIcon: UIImageView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!


    @IBOutlet weak var searchView: UIView!

    @IBAction func cancelTapped(_ sender: UIButton) {
        glassIcon.tintColor = UIColor.gray
        searchField.text = ""
        searchField.resignFirstResponder()
        cancelButton.layer.borderWidth = 0
        cancelButton.titleLabel?.textColor = UIColor.darkGray
        cancelButton.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        collectionView.contentInset.top = 60
        searchTextInput(searchField)

        //MARK-layout settings
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 4
            layout.minimumInteritemSpacing = 0
        }
        //MARK-refresher
        let refresher = PullToRefresh()
        collectionView.addPullToRefresh(refresher) {
            self.photos = []
            self.getExploreFlickrPhotos(pageNumber: 1) {
                print("POPULAR PHOTOS REFRESHED")
                self.currentLoadedPage = 1
            }
        }

        //Mark-first request
        getExploreFlickrPhotos(pageNumber: 1) {
            self.currentLoadedPage = 1
        }
    }

    private func requestAndParse(flickrUrlString: String) {
        request = Alamofire.request(flickrUrlString).responseJSON { [weak self] response in
            guard response.result.isSuccess else {
                print("REQUEST ERROR\(String(describing: response.result.error))")
                return
            }
            guard let photoData = response.data else {
                return
            }
            let flickrPhotos = try? JSONDecoder().decode(FlickrPhotos.self, from: photoData)
            guard let photoArray = flickrPhotos?.photos.photo else {
                self?.ShowErrorMessage()
                return
            }

            let validatedArray = photoArray.filter {
                $0.isPhotoSizeValid()
            }

            if self?.photos.count == 0 {
                self?.photos = validatedArray
            } else {
                self?.photos += validatedArray
            }
            guard let allPhotos = self?.photos,
                  let justifiedLayoutPics = self?.calculateJustifiedSizes(photos: allPhotos) else {
                return
            }
            self?.justifiedSizes = justifiedLayoutPics
            print("PHOTOS ARRAY COUNT IS \(String(describing: self?.justifiedSizes.count))")
            self?.collectionView.reloadData()
            self?.activityIndicator.stopAnimating()
            self?.collectionView.endAllRefreshing()
        }
    }

    //MARK - Explore photos requesting
    private func getExploreFlickrPhotos(pageNumber: Int, completion: @escaping () -> ()) {
        self.activityIndicator.startAnimating()

        let requestUrl = FlickrURL()
        let flickrUrlString = requestUrl.baseUrl +
        requestUrl.popularPhotosQuery +
        requestUrl.apiKey +
        requestUrl.extras +
        requestUrl.recentPhotosPerPage +
        requestUrl.page +
        String(pageNumber) +
        requestUrl.format
        requestAndParse(flickrUrlString: flickrUrlString)
        completion()
    }

    //MARK - Search requesting
    func searchTextInput(_ textField: UITextField) {
        searchField.delegate = self
    }

    private func flickrPhotosSearch(searchText: String, pageNumber: Int, completion: @escaping () -> ()) {
        currentSearch = searchText
        print("Current SEARCH is \(String(describing: currentSearch))")

        let requestUrl = FlickrURL()
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

        requestAndParse(flickrUrlString: flickrUrlString)
        self.currentLoadedPage = pageNumber
        completion()
    }

    //Mark - Error Message
    private func ShowErrorMessage() {
        let error = UIAlertController(
                title: "Error",
                message: "Explore photos not set",
                preferredStyle: .alert
        )
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("FETCHING ERROR")
        })
        error.addAction(ok)
        self.present(error, animated: true, completion: nil)
        self.collectionView.endAllRefreshing()
        self.activityIndicator.stopAnimating()
    }

    //MARK - Justified Layout Calculation
    private func calculateJustifiedSizes(photos: [Photo]) -> [CGSize] {
        var unfetchedSizes: [CGSize] = []
        for item in photos {
            guard
                    let width = Int(item.width_m),
                    let height = Int(item.height_m) else {
                return []
            }
            let size = CGSize(width: width, height: height)
            unfetchedSizes.append(size)
        }
        let tempJustifiedSizes = unfetchedSizes.lay_justify(for: 370, preferredHeight: 180)
        return tempJustifiedSizes
    }
}

// MARK: UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard justifiedSizes.count != 0 else {
            return CGSize(width: 0.5, height: 0.5)
        }
        return justifiedSizes[indexPath.item]
    }

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

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let desVC = mainStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        desVC.photos = self.photos
        desVC.selectedIndex = indexPath
        show(desVC, sender: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        print("GESTURE_COORDINATE =\(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y)")
        print("TopConstraint = \(searchViewTopConstraint.constant)")
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0, searchViewTopConstraint.constant >= -80 {
            searchViewTopConstraint.constant = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y
            self.collectionView.contentInset.top = 0
        } else {
            if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0, searchViewTopConstraint.constant <= -5 {
                searchViewTopConstraint.constant += 5
                self.collectionView.contentInset.top = 56
            }
        }

        guard let requestIsFinished = request?.progress.isFinished,
              requestIsFinished else {
            return
        }
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height {
            self.activityIndicator.startAnimating()
            guard let searchTag = currentSearch else {
                getExploreFlickrPhotos(pageNumber: currentLoadedPage + 1) {
                    self.currentLoadedPage += 1
                    print("One more explore page loaded. CURRENT PAGE IS \(self.currentLoadedPage)")
                }
                return
            }
            print("Loading next page. Current page now is \(currentLoadedPage)")
            flickrPhotosSearch(searchText: searchTag, pageNumber: currentLoadedPage + 1) {
                print("One more search page loaded. CURRENT PAGE IS \(self.currentLoadedPage)")
            }
        }
    }
}

extension SearchViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchField.returnKeyType = UIReturnKeyType.search
        glassIcon.tintColor = UIColor.white
        cancelButton.layer.borderWidth = 2
        cancelButton.titleLabel?.textColor = UIColor.white
        cancelButton.layer.borderColor = UIColor.white.cgColor
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let searchTag = searchField.text, searchTag != "" else {
            return
        }
        self.photos = []
        flickrPhotosSearch(searchText: searchTag, pageNumber: 1) {
        }
    }
}
