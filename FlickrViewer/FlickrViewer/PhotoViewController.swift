//
//  PhotoViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import Alamofire

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    var comments: [Comment] = []
    var flickrPhoto: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if flickrPhoto != nil {
            photoImageView.sd_setImage(with: flickrPhoto!.photoUrl as URL?)
        }
        largePhotoRequest()
    }
    
    private func largePhotoRequest(){
        let requestUrl: String = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=4b3a3f61c9980336cc603ab62a100a76&photo_id=\(flickrPhoto?.id ?? "42917344375")&format=json&nojsoncallback=1"
        Alamofire.request(requestUrl).responseJSON{response in
            guard let photoSizesData = response.data else{return}
            let largePhoto = try? JSONDecoder().decode(FlickrPhotosSizes.self, from: photoSizesData)
            dump(largePhoto)
            
            self.photoImageView.sd_setImage(with: largePhoto?.sizes.size[4].source as URL?)
        }
    }
}


