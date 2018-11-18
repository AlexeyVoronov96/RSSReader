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
    
    func configureMessages(indexPath: IndexPath, rssItems: [RSSItem]) {
        let currentItem = rssItems[indexPath.row]
        titleLabel.text = currentItem.title
        descriptionLabel.text = currentItem.description
        dateLabel.text = currentItem.pubDate
    }
    
    func configureImages(indexPath: IndexPath, imgs: [String]) {
        let currentImage = imgs[indexPath.row]
        if currentImage != "" {
            heightConstraint.constant = newsImage.frame.width / 16 * 9
            let url = URL(string: currentImage)
            newsImage.kf.indicatorType = .activity
            newsImage.kf.setImage(with: url)
        } else {
            newsImage.image = nil
            heightConstraint.constant = 0
        }
    }
    
    func configureSavedMessages(indexPath: IndexPath, feed: FeedsList) {
        let currentItem = feed.messagesSorted[indexPath.row]
        titleLabel.text = currentItem.title
        descriptionLabel.text = currentItem.desc
        dateLabel.text = currentItem.pubDate
        newsImage.image = nil
        heightConstraint.constant = 0
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
