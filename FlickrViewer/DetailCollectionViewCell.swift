//
//  DetailCollectionViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/09/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import SDWebImage


protocol DetailViewCellDelegate: class {
    func close()
    var isTopViewHidden: Bool {get set}
}

class DetailCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentImage: UIImageView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topGradientView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomGradientView: UIView!
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var countViews: UILabel!
    
    
    @IBAction func detailViewClosing(_ sender: UIButton) {
        detailDelegate?.close()
    }
    
    var detailDelegate: DetailViewCellDelegate?
    var definedSize: CGSize?
    var isImageZoomed = false
    var isTopViewHidden = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //MARK - gradient top
        let topGradientLayer = CAGradientLayer()
        topGradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        topGradientLayer.startPoint = CGPoint(x: 1, y: 0)
        topGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        topGradientLayer.frame = topGradientView.bounds
        topGradientView.layer.addSublayer(topGradientLayer)
        
        //MARK - gradient bottom
        let bottomGradientLayer = CAGradientLayer()
        bottomGradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        bottomGradientLayer.startPoint = CGPoint(x: 1, y: 1)
        bottomGradientLayer.endPoint = CGPoint(x: 1, y: 0)
        bottomGradientLayer.frame = bottomGradientView.bounds
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        
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
    
    @objc private func tap() {
        guard let detailDelegate = detailDelegate else {
            return
        }
        topView.isHidden = !topView.isHidden
        detailDelegate.isTopViewHidden = !detailDelegate.isTopViewHidden
        bottomView.isHidden = !bottomView.isHidden
        
    }
    
    @objc func doubleTap() {
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
    
    func detailViewContentSet(flickrPhoto: Photo) {
        
        //MARK - avatar set
        avatar.layer.borderWidth = 1
        avatar.layer.masksToBounds = false
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
        
        //MARK - labels set
        avatar.sd_setImage(with: flickrPhoto.avatarURL as URL?)
        usernameLabel.text = flickrPhoto.ownername
        
        photoTitle.text = flickrPhoto.title
        countViews.text = "Views \(flickrPhoto.views)"
        
        //MARK - photo set
        currentImage.sd_setImage(with: NSURL(string: flickrPhoto.url_t) as URL?) { (image, error, cache, url) in
            self.currentImage.sd_setImage(with: NSURL(string: flickrPhoto.url_c) as URL?, placeholderImage: self.currentImage.image)
        }
        
        //MARK - top/bottom views control
        guard let detailDelegate = detailDelegate else {
            return
        }
        print(detailDelegate.isTopViewHidden)
        topView.isHidden = detailDelegate.isTopViewHidden
        bottomView.isHidden = detailDelegate.isTopViewHidden
        scrollView.zoomScale = 1
        isImageZoomed = false
    }
}
