//
//  FeedsList+CoreDataProperties.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 25/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import Foundation
import CoreData


extension FeedsList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedsList> {
        return NSFetchRequest<FeedsList>(entityName: "FeedsList")
    }

    @NSManaged public var name: String?
    @NSManaged public var link: String?
    @NSManaged public var feed: NSSet?

}

// MARK: Generated accessors for feed
extension FeedsList {

    @objc(addFeedObject:)
    @NSManaged public func addToFeed(_ value: Feed)

    @objc(removeFeedObject:)
    @NSManaged public func removeFromFeed(_ value: Feed)

    @objc(addFeed:)
    @NSManaged public func addToFeed(_ values: NSSet)

    @objc(removeFeed:)
    @NSManaged public func removeFromFeed(_ values: NSSet)

}
