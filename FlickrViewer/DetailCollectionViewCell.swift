//
//  DetailCollectionViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/09/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import SDWebImage

class DetailCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var currentImage: UIImageView!
    //let currentImage: UIImageView? = nil
    func setupWithPhoto(flickrPhoto: Photo) {
        currentImage?.sd_setImage(with: flickrPhoto.photoUrl as URL?)
    }
}
