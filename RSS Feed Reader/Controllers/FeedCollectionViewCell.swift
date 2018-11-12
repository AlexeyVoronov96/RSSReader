//
//  FeedCollectionViewCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import Kingfisher

class FeedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var newsImage: UIImageView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    var item: RSSItem! {
        didSet {
            titleLabel.text = item.title
            dateLabel.text = item.pubDate
            descriptionLabel.text = item.description
        }
    }
    
    var image: String! {
        didSet {
            let url = URL(string: image)
            newsImage.kf.indicatorType = .activity
            newsImage.kf.setImage(with: url)
        }
    }
    
    var savedItem: Feed! {
        didSet {
            titleLabel.text = savedItem.title
            descriptionLabel.text = savedItem.desc
            dateLabel.text = savedItem.pubDate
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
}
