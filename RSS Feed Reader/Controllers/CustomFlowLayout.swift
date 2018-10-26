//
//  CustomFlowLayout.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 24/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

private let separatorDecorationView = "separator"

final class CustomFlowLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationView)
        minimumLineSpacing = 8
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect) ?? []
        let lineWidth = self.minimumLineSpacing
        
        var decorationAttributes: [UICollectionViewLayoutAttributes] = []
        
        // skip first cell
        for layoutAttribute in layoutAttributes where layoutAttribute.indexPath.item > 0 {
            let separatorAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: separatorDecorationView,
                                                                      with: layoutAttribute.indexPath)
            let cellFrame = layoutAttribute.frame
            separatorAttribute.frame = CGRect(x: cellFrame.origin.x,
                                              y: cellFrame.origin.y - lineWidth,
                                              width: cellFrame.size.width,
                                              height: lineWidth)
            separatorAttribute.zIndex = Int.max
            decorationAttributes.append(separatorAttribute)
        }
        
        return layoutAttributes + decorationAttributes
    }
    
}

private final class SeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Colors().blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.frame = layoutAttributes.frame
    }
}
