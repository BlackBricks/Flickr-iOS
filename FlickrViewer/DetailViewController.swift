//
//  DetailViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/09/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import SDWebImage


class DetailViewController: UIViewController, DetailViewCellDelegate {
    
    var isTopViewHidden = false
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos: [Photo] = []
    var selectedIndex: IndexPath? = nil
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let indexToScroll = selectedIndex else {
            return
        }
        collectionView.scrollToItem(at: indexToScroll, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true) 
    }
    
    //MARK - Detail View closing function
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as? DetailCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.detailViewContentSet(flickrPhoto: photos[indexPath.row])
        cell.detailDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
