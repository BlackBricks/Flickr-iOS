//
//  ImageCollectionViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//


import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    func setupWithPhoto(flickrPhoto: Photo) {
        imageView.sd_setImage(with: NSURL(string: flickrPhoto.url_t) as URL?)
        { (image, error, cache, url) in
            self.imageView.sd_setImage(with: NSURL(string: flickrPhoto.url_m) as URL?, placeholderImage: self.imageView.image)
            
        }
        
    }
}
