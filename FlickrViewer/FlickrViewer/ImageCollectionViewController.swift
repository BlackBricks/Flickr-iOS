//
//  ImageCollectionViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 04/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit


class ImageCollectionViewController: UICollectionViewController {
    
    typealias FlickrResponse = (NSError?, [Commentary]?) -> Void
    
    var photos: [FlickrPhoto]=[]
    var commentaries:[Commentary]=[]
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let photoViewController = mainStoryboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        photoViewController.flickrPhoto = photos[indexPath.row]
        
        commentaryLoading(photoId: photos[indexPath.row].photoId, onCompletion: { (error: NSError?, commentaries: [Commentary]?) -> Void in
            if error == nil {
                self.commentaries = commentaries!
                print("COMMENTS ARE SET")
                            } else {
                self.commentaries = []
                if (error!.code == FlickrSearchRequest.Errors.invalidAccessErrorCode) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.showErrorAlert()
                    })
                }
            }
            photoViewController.commentaries = commentaries!
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1/2),execute:{
            self.navigationController?.pushViewController(photoViewController, animated: true)})
    }
    
    struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    func commentaryLoading( photoId:String, onCompletion: @escaping FlickrResponse) -> Void {
        print("START FETCHING COMMENTS")
        print("photoID\(photoId)")
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.comments.getList&api_key=1ebbbfd26e664bd73f3dd4f88153e6e3&photo_id=\(photoId)&format=json&nojsoncallback=1"
        let url: NSURL = NSURL(string: urlString)!
        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            if error != nil {
                print("Error fetching comments: \(error ?? 0 as! Error)")
                onCompletion(error as NSError?, nil)
                return
            }
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == Errors.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        onCompletion(invalidAccessError, nil)
                        return
                    }
                }
                
                guard let commentsContainer = resultsDictionary!["comments"] as? NSDictionary else { return }
                guard let commentsArray = commentsContainer["comment"] as? [NSDictionary] else { return }
                
                let commentaries: [Commentary] = commentsArray.map { commentDictionary in
                    
                    let commentaryAuthor = commentDictionary["authorname"] as? String ?? ""
                    let commentaryText = commentDictionary["_content"] as? String ?? ""
                    
                    let commentary = Commentary(commentaryAuthor:commentaryAuthor,commentaryText:commentaryText)
                    
                    return commentary
                }
                
                onCompletion(nil, commentaries)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(error, nil)
                return
            }
        })
        searchTask.resume()
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Search Error", message: "Invalid API Key", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
