//
//  DetailCollectionViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/09/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import SDWebImage

class DetailCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var detailViewClosing: UIButton!
    
    
    var definedSize: CGSize?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.addGestureRecognizer(tapRecognizer)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
    }
    
    @objc private func tap(){
        topView.isHidden = !topView.isHidden
        bottomView.isHidden = !bottomView.isHidden
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard let definedSize = definedSize else {
            return currentImage
        }
       currentImage.frame.size = definedSize
        return currentImage
    }
    
    func setupWithPhoto(flickrPhoto: Photo) {
        let width = flickrPhoto.size().width
        let height = flickrPhoto.size().height
        let aspectRatio = width/height
        let newWidth = self.frame.size.width
        let newHeight = CGFloat(height/aspectRatio)
        definedSize = CGSize(width: newWidth, height: newHeight)
        currentImage.frame.size = CGSize(width: newWidth, height: newHeight)
        currentImage.frame.origin.y = self.frame.midY - newHeight/2
        currentImage?.sd_setImage(with: flickrPhoto.photoUrl as URL?)
    }
}
