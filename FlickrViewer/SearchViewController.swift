//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController, UISearchBarDelegate, RecentSearchCellDelegate {

    private var photos: [Photo] = []
    private var justifiedSizes: [CGSize] = []
    private var request: DataRequest? = nil
    private var currentLoadedPage = 0
    private var currentSearch: String? = nil
    private var searchBarIsHidden = false
    private var recentSearches: [String] = []
    private let recentSearchesCellHeight: Int = 44
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private var lastContentOffset: CGFloat = -60

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var glassIcon: UIImageView!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var recentSearchesTableView: UITableView!

    @IBAction func textDidChange(_ sender: UITextField) {
        recentSearchesTableView.isHidden = true
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        glassIcon.tintColor = UIColor.gray
        searchField.text = ""
        searchField.resignFirstResponder()
        cancelButton.alpha = 0
        recentSearchesTableView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        collectionView.contentInset.top = 60
        collectionView.showsVerticalScrollIndicator = false
        searchTextInput(searchField)
        recentSearchesTableView.isHidden = true
        cancelButton.alpha = 0

        //MARK-layout settings
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 4
            layout.minimumInteritemSpacing = 0
        }
        //MARK-refresher
        refreshControl.addTarget(self, action: #selector(SearchViewController.refresh), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)

        //Mark-first request
        getExploreFlickrPhotos(pageNumber: 1) {
            self.currentLoadedPage = 1
        }
    }

    @objc func refresh() {
        self.photos = []
        self.justifiedSizes = []
        self.getExploreFlickrPhotos(pageNumber: 1) {
            self.refreshControl.endRefreshing()
            print("POPULAR PHOTOS REFRESHED")
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
            guard
                    let justifiedLayoutPics = self?.calculateJustifiedSizes(photos: validatedArray) else {
                return
            }
            self?.justifiedSizes += justifiedLayoutPics
            print("PHOTOS ARRAY COUNT IS \(String(describing: self?.photos.count))")
            self?.collectionView.reloadData()
            self?.activityIndicator.stopAnimating()
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
        activityIndicator.startAnimating()
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
        self.refreshControl.endRefreshing()
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
        var tempJustifiedSizes: [CGSize] = []
        tempJustifiedSizes = unfetchedSizes.lay_justify(for: 370, preferredHeight: 180)
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
        guard photos.count > 0 else {
            return cell
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

    func setSearchBarHide() {
        UIView.animate(withDuration: 0.4) {
            self.searchViewTopConstraint.constant = -80
            self.searchBarIsHidden = true
            self.searchView.layoutIfNeeded()
        }
    }

    func setSearchBarShow() {
        UIView.animate(withDuration: 0.4) {
            self.searchViewTopConstraint.constant = 0
            self.searchBarIsHidden = false
            self.searchView.layoutIfNeeded()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        recentSearchesTableView.isHidden = true

        //MARK - Search Bar Scroll Hiding
        var scrollingUp = false

        if scrollView.contentOffset.y > lastContentOffset {
            scrollingUp = true
            
        } else {
            scrollingUp = false
        }
        lastContentOffset = scrollView.contentOffset.y
        
        if scrollView.contentOffset.y > 0 {
            if searchBarIsHidden, !scrollingUp {
                setSearchBarShow()
            }
            if !searchBarIsHidden, scrollingUp {
                setSearchBarHide()
            }
        } else {
            if searchBarIsHidden, scrollView.contentOffset.y < 60, scrollView.contentOffset.y > -60 {
                setSearchBarShow()
            }
        }

        //MARK - Pagination
        guard let requestIsFinished = request?.progress.isFinished,
              requestIsFinished else {
            return
        }
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height * 2 {
            self.activityIndicator.startAnimating()
            collectionView.contentInset.bottom = 60
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
        searchField.text? = ""
        searchField.returnKeyType = UIReturnKeyType.search
        glassIcon.tintColor = UIColor.white
        cancelButton.alpha = 1

        cancelButton.layer.borderWidth = 2
        cancelButton.titleLabel?.textColor = UIColor.white
        cancelButton.layer.borderColor = UIColor.white.cgColor

        if !recentSearches.isEmpty {
            self.recentSearchesTableView.isHidden = false
        }
        guard let searchTextIsEmpty = searchField.text?.isEmpty else {
            return
        }
        if !searchTextIsEmpty {
            recentSearchesTableView.isHidden = true
        }
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
        self.justifiedSizes = []
        flickrPhotosSearch(searchText: searchTag, pageNumber: 1) {

            //MARK - RecentSearchesUpdate
            self.recentSearches.append(searchTag)
            self.tableHeight.constant = CGFloat(self.recentSearchesCellHeight * self.recentSearches.count)
            self.recentSearchesTableView.reloadData()
            print("Recent searches: \(self.recentSearches)")

            //MARK - AutoScrollToCollectionViewTop
            self.collectionView.setContentOffset(CGPoint.zero, animated: false)
            self.collectionView.reloadData()
        }
    }
}

//MARK - Recent Searches Table View
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func removeCell(cell: RecentSearchTableViewCell, indexPath: IndexPath) {
        let index = indexPath
        recentSearches.remove(at: index.row)
        self.recentSearchesTableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableHeight.constant = CGFloat(44 * recentSearches.count)
        return recentSearches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearch", for: indexPath) as? RecentSearchTableViewCell else {
            return UITableViewCell()
        }
        cell.recentSearchSet(recentSearch: recentSearches[indexPath.row])
        cell.recentSearchCellDelegate = self as RecentSearchCellDelegate
        cell.cellIndex = indexPath
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.photos = []
        self.justifiedSizes = []
        recentSearchesTableView.isHidden = true
        searchField.text = recentSearches[indexPath.row]

        flickrPhotosSearch(searchText: recentSearches[indexPath.row], pageNumber: 1) {
            self.collectionView.reloadData()
        }
    }
}
