//
//  FeedItemCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import Kingfisher

protocol FeedItemCellDelegate: class {
    func didTapOnMoreButton(_ cell: FeedItemCell)
}

class FeedItemCell: UICollectionViewCell {
    enum LayoutState {
        case highlighted
        case normal
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView!
    
    weak var delegate: FeedItemCellDelegate?
    
    var feedItem: Feed? {
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
    
    var favoriteItem: SavedMessages? {
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 8
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.masksToBounds = true
        
        layer.shadowRadius = 6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.masksToBounds = false
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        transform(with: .highlighted)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        transform(with: .normal)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        transform(with: .normal)
    }
    
    @IBAction private func moreButtonAction(_ sender: UIButton) {
        delegate?.didTapOnMoreButton(self)
    }
    
    private func transform(with state: LayoutState) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.2,
                       options: .beginFromCurrentState,
                       animations: { [weak self] in
                        switch state {
                        case .highlighted:
                            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                            
                        case .normal:
                            self?.transform = .identity
                        }
            },
                       completion: nil)
    }
}
