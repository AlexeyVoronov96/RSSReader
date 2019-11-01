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
    class func newMessage(title: String, desc: String, pubDate: Date, link: String, image: String) -> SavedMessages {
        let message = SavedMessages(context: CoreDataManager.shared.managedObjectContext)
        message.title = title
        message.desc = desc
        message.pubDate = pubDate
        message.link = link
        message.image = image
        return message
    }
}
