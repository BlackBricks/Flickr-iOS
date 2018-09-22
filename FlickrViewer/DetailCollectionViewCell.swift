//
//  DetailCollectionViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/09/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import SDWebImage
//import ZoomImageView

protocol DetailViewCellDelegate {
    func close()
}

class DetailCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentImage:UIImageView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var countViews: UILabel!
    
    
    @IBAction func detailViewClosing(_ sender: UIButton) {
        detailDelegate?.close()
    }
    
    var detailDelegate: DetailViewCellDelegate?
    var definedSize: CGSize?
    var isImageZoomed = false {
        didSet {
            print (isImageZoomed)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapRecognizer)
        
        tapRecognizer.require(toFail: doubleTapRecognizer)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            isImageZoomed = true
        } else {
            isImageZoomed = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let leftMargin = (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5
        let topMargin = (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5
        scrollView.contentInset = UIEdgeInsets(top: max(0, topMargin), left: max(0, leftMargin), bottom: 0, right: 0)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return currentImage
    }
    
    @objc private func tap(){
        topView.isHidden = !topView.isHidden
        bottomView.isHidden = !bottomView.isHidden
        
    }
    
    @objc func doubleTap(){
        if isImageZoomed {
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.scrollView.zoomScale = 1
                self?.isImageZoomed = false
            }
        } else {
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.scrollView.zoomScale = 3
                self?.isImageZoomed = true
            }
        }
    }
    
    func detailViewContentSet(flickrPhoto: Photo){
        avatar.sd_setImage(with: flickrPhoto.avatarURL as URL?)
        usernameLabel.text = flickrPhoto.ownername
        
        photoTitle.text = flickrPhoto.title
        countViews.text = "Views \(flickrPhoto.views)"
        
        currentImage.sd_setImage(with: NSURL(string: flickrPhoto.url_t) as URL?)
        { (image, error, cache, url) in
            self.currentImage.sd_setImage(with: NSURL(string: flickrPhoto.url_c) as URL?, placeholderImage: self.currentImage.image)
        }
        scrollView.zoomScale = 1
        isImageZoomed = false
    }
}
