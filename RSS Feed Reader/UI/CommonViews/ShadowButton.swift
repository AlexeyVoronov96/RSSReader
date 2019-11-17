//
//  ShadowButton.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 17.11.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import UIKit

class ShadowButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = false
        
        layer.cornerRadius = 8
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
        
        layer.shadowRadius = 2
        layer.shadowColor = (UIColor(named: "Black") ?? UIColor.black).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
    }
}
