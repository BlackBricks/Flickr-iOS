//
//  SearchViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class SearchViewController: UIViewController, UISearchBarDelegate, RecentSearchCellDelegate {
    
    //MARK: - Variables
    private var explorePhotos: [Photo] = []
    private var searchPhotos: [Photo] = []
    private var justifiedSizes: [CGSize] = []
    private var request: DataRequest? = nil
    private var currentLoadedPage = 0
    private var currentSearch: String? = nil
    private var searchBarIsVisible = true
    private var searchModeIsOn = false
    private var recentSearchesIsVisible = false
    private var recentSearches: [String] = []
    private let recentSearchesCellHeight: Int = 44
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private var lastContentOffset: CGFloat = -56
    private let basicOffset: CGFloat = 4
    private let layoutPreferredHeight: CGFloat = 120

    //MARK: - Outlets
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var glassIcon: UIImageView!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exploreCollectionView: UICollectionView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var recentSearchesTableView: UITableView!
    @IBOutlet weak var searchResultsView: UIView!
    @IBOutlet weak var searchResultsCollectionView: UICollectionView!

    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIApplication.shared.statusBarView?.backgroundColor = UIColor.gray
        activityIndicator.startAnimating()
        exploreCollectionView.contentInset.top = searchBarView.frame.height + basicOffset
        exploreCollectionView.showsVerticalScrollIndicator = false
        searchResultsCollectionView.contentInset.top = searchBarView.frame.height + basicOffset
        searchResultsCollectionView.showsVerticalScrollIndicator = false
        searchResultsCollectionView.isHidden = true
        searchTextInput(searchField)
        recentSearchesTableView.layer.opacity = 0
        cancelButton.alpha = 0
        searchResultsView.layer.opacity = 0

        

        //MARK: - refresher
        refreshControl.addTarget(self, action: #selector(SearchViewController.refresh), for: .valueChanged)
        self.exploreCollectionView.addSubview(refreshControl)

        
        self.exploreCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        self.searchResultsCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        //MARK: - justified layouts settings

        if let layout = exploreCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = basicOffset
            layout.sectionInset.left = -4
            layout.sectionInset.right = -4
        }
        
        if let layout = searchResultsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = basicOffset/2
            layout.sectionInset.left = basicOffset/2
            layout.sectionInset.right = basicOffset/2
        }
        
        //Mark: - first request
        getExploreFlickrPhotos(pageNumber: 1) {
            self.currentLoadedPage = 1
        }
    }
    
    @objc func refresh() {
        self.explorePhotos = []
        self.justifiedSizes = []
        self.getExploreFlickrPhotos(pageNumber: 1) {
            self.refreshControl.endRefreshing()
            print("POPULAR PHOTOS REFRESHED")
            self.currentLoadedPage = 1
        }
    }
    
    //MARK: - Functions
    private func requestAndParse(flickrUrlString: String) {
        print("\(flickrUrlString)")
        request = Alamofire.request(flickrUrlString).responseJSON { [weak self] response in
            guard let weakself = self else {
                return
            }

            guard response.result.isSuccess else {
                print("REQUEST ERROR\(String(describing: response.result.error))")
                return
            }

            guard let photoData = response.data else {
                return
            }
            let flickrPhotos = try? JSONDecoder().decode(FlickrPhotos.self, from: photoData)
            
            guard let photoArray = flickrPhotos?.photos.photo else {
                weakself.showErrorMessage()
                return
            }

            let validatedArray = photoArray.filter {
                $0.isPhotoSizeValid()
            }

            if weakself.searchModeIsOn {
                if weakself.searchPhotos.count == 0 {
                    weakself.searchPhotos = validatedArray
                } else {
                    weakself.searchPhotos += validatedArray
                }
            } else {
                if weakself.explorePhotos.count == 0 {
                    weakself.explorePhotos = validatedArray
                } else {
                    weakself.explorePhotos += validatedArray
                }
            }
            var justifiedLayoutPics: [CGSize] = []
            if weakself.searchModeIsOn {
                justifiedLayoutPics = weakself.calculateJustifiedSizes(photos: validatedArray, layoutWidth: weakself.searchResultsCollectionView.frame.width)
            } else {
                justifiedLayoutPics = weakself.calculateJustifiedSizes(photos: validatedArray, layoutWidth: weakself.exploreCollectionView.frame.width)
            }

            weakself.justifiedSizes += justifiedLayoutPics

            print("SEARCH PHOTOS ARRAY COUNT IS \(String(describing: self?.searchPhotos.count))")
            print("EXPLORE PHOTOS ARRAY COUNT IS \(String(describing: self?.explorePhotos.count))")

            if weakself.searchModeIsOn {
                weakself.searchResultsCollectionView.reloadData()
                weakself.searchResultsCollectionView.contentInset.top = weakself.searchBarView.frame.height + weakself.basicOffset
            } else {
                weakself.exploreCollectionView.reloadData()
            }
            weakself.activityIndicator.stopAnimating()
        }
    }

    //MARK: - Explore photos requesting
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

    //MARK: - Search requesting
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

    //MARK: - Error Message
    private func showErrorMessage() {
        let error = UIAlertController(
                title: "Error",
                message: "Photos not set",
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

    //MARK: - Justified Layout Calculation
    private func calculateJustifiedSizes(photos: [Photo], layoutWidth: CGFloat) -> [CGSize] {
        var unfetchedSizes: [CGSize] = []
        for item in photos {
            let size = CGSize(width: item.width_m, height: item.height_m)
            unfetchedSizes.append(size)
        }
        var tempJustifiedSizes: [CGSize] = []
        tempJustifiedSizes = unfetchedSizes.lay_justify(for: layoutWidth - basicOffset * 3, preferredHeight: self.view.frame.height/5)
        return tempJustifiedSizes
    }
    
    //MARK: - @IBActions
    @IBAction func textDidChange(_ sender: UITextField) {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.recentSearchesTableView.layer.opacity = 0
        }, completion: nil)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        searchModeIsOn = false
        searchField.text = ""
        
        currentSearch = nil
        searchPhotos = []
        searchField.resignFirstResponder()
        request?.cancel()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.recentSearchesTableView.layer.opacity = 0
            self?.glassIcon.tintColor = UIColor.gray
            self?.cancelButton.alpha = 0
            self?.searchResultsView.layer.opacity = 0
        }, completion: nil)
        searchResultsCollectionView.reloadData()
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == exploreCollectionView {
            return explorePhotos.count
        } else {
            return searchPhotos.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard explorePhotos.count > 0 || searchPhotos.count > 0 else {
            return cell
        }

        if collectionView == exploreCollectionView {
            guard indexPath.row < explorePhotos.count else {
                print("IndexPath is out of range")
                return cell
            }
            cell.configFor(flickrPhoto: explorePhotos[indexPath.row])
        } else {
            guard indexPath.row < searchPhotos.count else {
                print("IndexPath is out of range")
                return cell
            }
            cell.configFor(flickrPhoto: searchPhotos[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard justifiedSizes.count != 0 else {
            return CGSize(width: 0.5, height: 0.5)
        }
        guard indexPath.row < explorePhotos.count else {
            print("IndexPath is out of range")
            return CGSize(width: 0.5, height: 0.5)
        }
        return justifiedSizes[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let desVC = mainStoryboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        desVC.selectedIndex = indexPath
        if collectionView == exploreCollectionView {
            desVC.photos = self.explorePhotos
        } else {
            desVC.photos = self.searchPhotos
        }
        desVC.modalPresentationStyle = .fullScreen
        self.present(desVC, animated: true, completion: nil)
    }

    //MARK: - Search Bar Scroll Hiding
    func setSearchBar(visibility: Bool) {
        guard searchBarIsVisible != visibility else {
            return
        }
        self.searchBarIsVisible = visibility
        var offset: CGFloat = 0
        if !visibility {
            offset = -self.searchBarView.frame.height
        }
        self.searchViewTopConstraint.constant = offset

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        recentSearchesTableView.isHidden = true

        var scrollingUp = false

        if scrollView.contentOffset.y > lastContentOffset {
            scrollingUp = true
        } else {
            scrollingUp = false
        }
        lastContentOffset = scrollView.contentOffset.y

        if !scrollingUp {
            setSearchBar(visibility: true)
        } else if scrollView.contentOffset.y > 0 {
            setSearchBar(visibility: false)
        }

        //MARK - Pagination
        guard let requestIsFinished = request?.progress.isFinished,
              requestIsFinished else {
            return
        }
        
        let scrollIsCloseToNextPage: Bool = scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height
        
        if scrollIsCloseToNextPage, scrollView.contentSize.height > 0 {
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
        searchModeIsOn = true
        searchField.text? = ""
        searchField.returnKeyType = UIReturnKeyType.search
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.glassIcon.tintColor = UIColor.white
            self?.cancelButton.alpha = 1
            self?.searchResultsView.layer.opacity = 1
            self?.searchResultsView.isHidden = false
            self?.searchResultsCollectionView.isHidden = false
        }, completion: nil)

        cancelButton.layer.borderWidth = 2
        cancelButton.titleLabel?.textColor = UIColor.white
        cancelButton.layer.borderColor = UIColor.white.cgColor

        if !recentSearches.isEmpty {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                self?.recentSearchesTableView.layer.opacity = 1
            }, completion: nil)
            recentSearchesTableView.isHidden = false
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
        self.searchPhotos = []
        self.justifiedSizes = []
        flickrPhotosSearch(searchText: searchTag, pageNumber: 1) {

            //MARK: - RecentSearchesUpdate
            guard !self.recentSearches.contains(searchTag) else {
                return
            }
            self.recentSearches.append(searchTag)
            self.tableHeight.constant = CGFloat(self.recentSearchesCellHeight * self.recentSearches.count)
            self.recentSearchesTableView.reloadData()
            print("Recent searches: \(self.recentSearches)")

            //MARK: - AutoScrollToCollectionViewTop
            self.searchResultsCollectionView.isHidden = false
            self.searchResultsCollectionView.setContentOffset(CGPoint(x: 0, y: -(self.searchBarView.frame.height + self.basicOffset)), animated: false)
            self.searchResultsCollectionView.reloadData()
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
        tableHeight.constant = CGFloat(recentSearchesCellHeight * recentSearches.count)
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
        self.searchPhotos = []
        self.justifiedSizes = []
        recentSearchesTableView.isHidden = true
        searchField.text = recentSearches[indexPath.row]

        flickrPhotosSearch(searchText: recentSearches[indexPath.row], pageNumber: 1) {
            self.searchResultsCollectionView.reloadData()
        }
    }
}
