//
//  FavoritesCollectionViewCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 27/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var newsImage: UIImageView!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // Specify you want _full width_
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        
        // Calculate the size (height) using Auto Layout
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        
        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
}
