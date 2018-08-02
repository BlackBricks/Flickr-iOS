//
//  PhotoViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var comments: [Comment] = []
    var flickrPhoto: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        if flickrPhoto != nil {
            photoImageView.sd_setImage(with: flickrPhoto!.photoUrl as URL?)
        }
    }
}
    //MARK: - UITableViewDataSource
extension PhotoViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commentary Cell", for: indexPath ) as? CommentaryTableViewCell
        cell!.commentSetup(comment: comments[indexPath.row])
        return cell!
    }
}
