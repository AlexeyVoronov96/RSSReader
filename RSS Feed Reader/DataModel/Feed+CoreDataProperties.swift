//
//  Feed+CoreDataProperties.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 25/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import Foundation
import CoreData


extension Feed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var pubDate: String?
    @NSManaged public var link: String?
    @NSManaged public var feedsList: FeedsList?

}
