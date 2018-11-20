//
//  SavedMessages+CoreDataProperties.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

extension SavedMessages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedMessages> {
        return NSFetchRequest<SavedMessages>(entityName: "SavedMessages")
    }

    @NSManaged public var title: String?
    @NSManaged public var link: String?
    @NSManaged public var pubDate: String?
    @NSManaged public var desc: String?
    @NSManaged public var image: String?

}
