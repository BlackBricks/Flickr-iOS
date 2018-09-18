//
//  RecentSearchTableViewCell.swift
//  FlickrViewer
//
//  Created by Кирилл Штеффен on 12.09.2018.
//  Copyright © 2018 BlackBricks. All rights reserved.
//

import UIKit

protocol RecentSearchCellDelegate {
    func removeCell(cell: RecentSearchTableViewCell, indexPath: IndexPath)
}

class RecentSearchTableViewCell: UITableViewCell {

    var recentSearch: String = ""
    var recentSearchCellDelegate: RecentSearchCellDelegate?
    var cellIndex: IndexPath?
    
    @IBOutlet weak var recenSearchLabel: UILabel!
    
    @IBAction func removeCell(_ sender: UIButton) {
        recentSearchCellDelegate?.removeCell(cell: self, indexPath: cellIndex!)
    }
    
    func recentSearchSet (recentSearch: String) {
        recenSearchLabel.text = recentSearch
    }
}
