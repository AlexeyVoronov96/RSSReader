//
//  NewsTableViewCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!{
        didSet {
            DescriptionLabel.numberOfLines = 3
        }
    }
    
    
    var item: RSSItem! {
        didSet{
            TitleLabel.text = item.title
            DateLabel.text = item.pubDate
            DescriptionLabel.text = item.description
        }
    }
    
}
