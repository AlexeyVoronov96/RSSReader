//
//  CoreDataManager.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 25/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import CoreData

var channels: [FeedsList] {
    let request = NSFetchRequest<FeedsList>(entityName: "FeedsList")
    let sd = NSSortDescriptor(key: "name", ascending: true)
    request.sortDescriptors = [sd]
    let array = try? CoreDataManager.sharedInstance.managedObjectContext.fetch(request)
    if array != nil {
        return array!
    }
    return []
}

var messages: [Feed] {
    let request = NSFetchRequest<Feed>(entityName: "Feed")
    let sd = NSSortDescriptor(key: "pubDate", ascending: true)
    request.sortDescriptors = [sd]
    let array = try? CoreDataManager.sharedInstance.managedObjectContext.fetch(request)
    if array != nil {
        return array!
    }
    return []
}

var message: [SavedMessages] {
    let request = NSFetchRequest<SavedMessages>(entityName: "SavedMessages")
    let array = try? CoreDataManager.sharedInstance.managedObjectContext.fetch(request)
    if array != nil {
        return array!.reversed()
    }
    return []
}

class CoreDataManager {
    
    static let sharedInstance = CoreDataManager()
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AppData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
