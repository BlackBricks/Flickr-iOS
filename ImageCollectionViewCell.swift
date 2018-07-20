//
//  ImageCollectionViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    
    func setupWithPhoto(flickrPhoto: FlickrPhoto) {
        print ("adding photo...")
        resultImageView.sd_setImage(with: flickrPhoto.photoUrl as URL?)
        
        
        
    }
    
}
