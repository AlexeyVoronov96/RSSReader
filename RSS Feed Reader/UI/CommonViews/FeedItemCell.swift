//
//  FeedItemCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import Kingfisher

class FeedItemCell: UICollectionViewCell {
    static let cellId = "FeedItemCell"
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView!
    
    var feedItem: FeedMessage? {
        didSet {
            titleLabel.text = feedItem?.title
            descriptionLabel.text = feedItem?.desc
            dateLabel.text = feedItem?.pubDate?.dateToString()
            
            if let url = URL(string: feedItem?.image ?? "") {
                newsImageView.kf.setImage(with: url)
            } else {
                newsImageView.isHidden = true
            }
        }
    }
    
    var favoriteItem: FavoriteMessage? {
        didSet {
            titleLabel.text = favoriteItem?.title
            descriptionLabel.text = favoriteItem?.desc
            dateLabel.text = favoriteItem?.pubDate?.dateToString()
            
            if let url = URL(string: favoriteItem?.image ?? "") {
                newsImageView.kf.setImage(with: url)
            } else {
                newsImageView.isHidden = true
            }
        }
    }
    
    var image: UIImage? {
        return newsImageView.image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.masksToBounds = true
        
        layer.shadowRadius = 3
        layer.shadowColor = (UIColor(named: "Black") ?? UIColor.black).cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.masksToBounds = false
        
        newsImageView.kf.indicatorType = .activity
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        newsImageView.image = nil
    }
}
