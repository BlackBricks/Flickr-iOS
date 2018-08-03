//
//  ImageCollectionViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import Alamofire

class ImageCollectionViewController: UICollectionViewController {
    
    var photos: [Photo]=[]
    var photoComments: [Comment]=[]
    private let flickrApiKey = "1ebbbfd26e664bd73f3dd4f88153e6e3"
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = mainStoryboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        photoViewController.flickrPhoto = photos[indexPath.row]
        commentsLoading(photoId: photos[indexPath.row].id)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),execute:{
            photoViewController.comments = self.photoComments
            self.navigationController?.pushViewController(photoViewController, animated: true)})
    }
    
    //MARK-comments
    func commentsLoading (photoId: String){
        print("Start requesting comments")
        let requestUrl: String = "https://api.flickr.com/services/rest/?method=flickr.photos.comments.getList&api_key=\(flickrApiKey)&photo_id=\(photoId)&format=json&nojsoncallback=1"
        Alamofire.request(requestUrl).responseJSON{response in
            guard response.data != nil else{return}
            let commentsArray = try? JSONDecoder().decode(FlickrComments.self, from: response.data!)
            dump(commentsArray)
            if commentsArray != nil {
                self.photoComments = (commentsArray?.comments.comment)!}
        }
    }
}
