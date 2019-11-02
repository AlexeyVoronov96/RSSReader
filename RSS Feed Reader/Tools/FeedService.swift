//
//  FeedService.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 02.11.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Foundation

class FeedService {
    static let shared = FeedService()
    
    var selectedFeed: FeedsList?
}
