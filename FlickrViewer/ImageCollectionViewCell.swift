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
        resultImageView.sd_setImage(with: NSURL(string: flickrPhoto.url_t) as URL?)
        { (image, error, cache, url) in
            self.resultImageView.sd_setImage(with: NSURL(string: flickrPhoto.url_m) as URL?, placeholderImage: self.resultImageView.image)
        }
    }
}
