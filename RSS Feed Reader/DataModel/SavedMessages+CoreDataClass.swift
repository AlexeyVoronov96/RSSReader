//
//  SavedMessages+CoreDataClass.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//
//

import CoreData

@objc(SavedMessages)
public class SavedMessages: NSManagedObject {
    class func newMessage(from feedItem: Feed?) {
        let message = SavedMessages(context: CoreDataManager.shared.managedObjectContext)
        message.title = feedItem?.title
        message.desc = feedItem?.desc
        message.pubDate = feedItem?.pubDate
        message.image = feedItem?.image
        message.savedDate = Date()
    }
}
