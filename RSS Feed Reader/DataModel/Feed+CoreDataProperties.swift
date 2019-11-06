//
//  Feed+CoreDataProperties.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

extension Feed {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged public var link: String?
    @NSManaged public var name: String?
    @NSManaged public var message: NSSet?
}

// MARK: Generated accessors for feed
extension Feed {
    @objc(addFeedObject:)
    @NSManaged public func addToFeed(_ value: FeedMessage)

    @objc(removeFeedObject:)
    @NSManaged public func removeFromFeed(_ value: FeedMessage)

    @objc(addFeed:)
    @NSManaged public func addToFeed(_ values: NSSet)

    @objc(removeFeed:)
    @NSManaged public func removeFromFeed(_ values: NSSet)
}
