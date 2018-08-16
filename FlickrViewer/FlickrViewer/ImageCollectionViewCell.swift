//
//  ImageCollectionViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//


import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    func setupWithPhoto(flickrPhoto: Photo) {
        //print ("adding photo...")
        resultImageView.sd_setImage(with: flickrPhoto.photoUrl as URL?)
    }
}
