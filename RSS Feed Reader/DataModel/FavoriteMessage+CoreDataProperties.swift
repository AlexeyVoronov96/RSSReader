//
//  FavoriteMessage+CoreDataProperties.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

extension FavoriteMessage {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMessage> {
        return NSFetchRequest<FavoriteMessage>(entityName: "FavoriteMessage")
    }

    @NSManaged public var title: String?
    @NSManaged public var link: String?
    @NSManaged public var pubDate: Date?
    @NSManaged public var desc: String?
    @NSManaged public var image: String?
    @NSManaged public var savedDate: Date?
}
