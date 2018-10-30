//
//  Feed+CoreDataClass.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Feed)
public class Feed: NSManagedObject {
    class func addFeed(title: String, desc: String, pubDate: String, link: String, inFeed: FeedsList?) -> Feed {
        let feed = Feed(context: CoreDataManager.sharedInstance.managedObjectContext)
        feed.title = title
        feed.desc = desc
        feed.pubDate = pubDate
        feed.link = link
        
        if let inFeed = inFeed {
            feed.feedsList = inFeed
        }
        return feed
    }
}
