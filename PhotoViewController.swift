//
//  PhotoViewController.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 06/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit
import Foundation

class PhotoViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var commentaries: [Commentary] = []
    var flickrPhoto: FlickrPhoto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        if flickrPhoto != nil {
            photoImageView.sd_setImage(with: flickrPhoto!.photoUrl as URL?)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commentary Cell", for: indexPath ) as? CommentaryTableViewCell
        cell!.commentSetup(comment: commentaries[indexPath.row])
        //cell!.commentaryText.text = "TESTING"
        
        return cell!
    }
    
    
    
}
