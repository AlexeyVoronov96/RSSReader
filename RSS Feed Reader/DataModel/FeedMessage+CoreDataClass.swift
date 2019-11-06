//
//  FeedMessage+CoreDataClass.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

@objc(FeedMessage)
public class FeedMessage: NSManagedObject {
    class func addFeed(title: String, desc: String, pubDate: Date, link: String, image: String, feed: Feed?) {
        let feedMessage = FeedMessage(context: CoreDataManager.shared.managedObjectContext)
        feedMessage.title = title
        feedMessage.desc = desc
        feedMessage.pubDate = pubDate
        feedMessage.link = link
        feedMessage.image = image
        
        if let feed = feed {
            feedMessage.feed = feed
        }
    }
}
