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
    class func newFeed(name: String, link: String) {
        let feed = Feed(context: CoreDataManager.shared.managedObjectContext)
        feed.name = name
        feed.link = link
    }
    
    var messagesSorted: [FeedMessage] {
        let sortDescriptor = NSSortDescriptor(key: "pubDate", ascending: false)
        return message?.sortedArray(using: [sortDescriptor]) as? [FeedMessage] ?? []
    }
}
