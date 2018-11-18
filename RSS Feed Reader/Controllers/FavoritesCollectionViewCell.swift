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
    
    func configureMessage(indexPath: IndexPath) {
        let currentMessage = message[indexPath.row]
        heightConstraint.constant = (currentMessage.image == "") ? 0 : newsImage.frame.width / 16 * 9
        if currentMessage.image != "" {
            let url = URL(string: currentMessage.image!)!
            newsImage.kf.indicatorType = .activity
            newsImage.kf.setImage(with: url)
        }
        titleLabel.text = currentMessage.title
        descriptionLabel.text = currentMessage.desc
        dateLabel.text = currentMessage.pubDate
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
