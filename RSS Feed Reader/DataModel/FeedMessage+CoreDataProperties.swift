//
//  FeedMessage+CoreDataProperties.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

extension FeedMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedMessage> {
        return NSFetchRequest<FeedMessage>(entityName: "FeedMessage")
    }

    @NSManaged public var desc: String?
    @NSManaged public var title: String?
    @NSManaged public var link: String?
    @NSManaged public var pubDate: Date?
    @NSManaged public var image: String?
    @NSManaged public var feed: Feed?
}
