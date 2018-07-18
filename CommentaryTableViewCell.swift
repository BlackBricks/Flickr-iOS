//
//  CommentaryTableViewCell.swift
//  FlickrViewer
//
//  Created by Kirill Shteffen on 13/07/2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit

class CommentaryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var author: UILabel!
    
    @IBOutlet weak var commentaryText: UILabel!
    
    func commentSetup(comment:Commentary){
        author.text = comment.commentaryAuthor
        commentaryText.text = comment.commentaryText
    }
    
}
