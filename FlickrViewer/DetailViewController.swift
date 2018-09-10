//
//  DetailViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/09/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import SDWebImage


class DetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var photos: [Photo] = []
    
    var selectedIndex: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView.scrollToItem(at: selectedIndex!, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
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
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }
}
