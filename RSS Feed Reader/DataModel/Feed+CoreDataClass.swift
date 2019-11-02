//
//  Feed+CoreDataClass.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

@objc(Feed)
public class Feed: NSManagedObject {
    class func addFeed(title: String, desc: String, pubDate: Date, link: String, image: String, inFeed: FeedsList?) {
        let feed = Feed(context: CoreDataManager.shared.managedObjectContext)
        feed.title = title
        feed.desc = desc
        feed.pubDate = pubDate
        feed.link = link
        feed.image = image
        
        if let inFeed = inFeed {
            feed.feedsList = inFeed
        }
    }
}
