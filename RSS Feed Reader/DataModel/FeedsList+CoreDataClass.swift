//
//  FeedsList+CoreDataClass.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

@objc(FeedsList)
public class FeedsList: NSManagedObject {
    class func newFeed(name: String, link: String) {
        let feed = FeedsList(context: CoreDataManager.shared.managedObjectContext)
        feed.name = name
        feed.link = link
    }
    
    func addFeed() -> Feed {
        let feed = Feed(context: CoreDataManager.shared.managedObjectContext)
        feed.feedsList = self
        return feed
    }
    
    var messagesSorted: [Feed] {
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        return self.feed?.sortedArray(using: [sortDescriptor]) as! [Feed]
    }
}
