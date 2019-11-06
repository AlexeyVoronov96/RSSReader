//
//  FeedCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 20/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    static let cellId = "FeedCell"
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    var feed: Feed? {
        didSet {
            nameLabel.text = feed?.name
            linkLabel.text = feed?.link
        }
    }
}
