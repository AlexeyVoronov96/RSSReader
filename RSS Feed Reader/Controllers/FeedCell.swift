//
//  FeedCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 20/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    var feed: FeedsList? {
        didSet {
            nameLabel.text = feed?.name
            linkLabel.text = feed?.link
        }
    }
}
