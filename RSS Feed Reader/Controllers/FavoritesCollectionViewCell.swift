//
//  FavoritesCollectionViewCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 27/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import Kingfisher

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var newsImage: UIImageView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    var message: SavedMessages! {
        didSet {
            heightConstraint.constant = (message.image == "") ? 0 : newsImage.frame.width / 16 * 9
            if message.image != "" {
                let url = URL(string: message.image!)!
                newsImage.kf.indicatorType = .activity
                newsImage.kf.setImage(with: url)
            }
            titleLabel.text = message.title
            descriptionLabel.text = message.desc
            dateLabel.text = message.pubDate
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
