//
//  CoreDataManager.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 25/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import CoreData

var favorites: [SavedMessages] {
    let request = NSFetchRequest<SavedMessages>(entityName: "SavedMessages")
    let array = try? CoreDataManager.shared.managedObjectContext.fetch(request)
    if array != nil {
        return array!.reversed()
    }
    return []
}

class CoreDataManager {
    static let shared = CoreDataManager()
    
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
    
    lazy var feedsListFetchedResultsController: NSFetchedResultsController<FeedsList> = {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<FeedsList>(entityName: "FeedsList")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<FeedsList>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
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
    
    func checkItem(with title: String, description: String) -> Bool {
        let fetchRequest = NSFetchRequest<Feed>(entityName: "Feed")
        fetchRequest.predicate = NSPredicate(format: "title = %@ && desc = %@", title, description)
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    func checkFavoriteItem(with feedItem: Feed?) -> SavedMessages? {
        let fetchRequest = NSFetchRequest<SavedMessages>(entityName: "SavedMessages")
        fetchRequest.predicate = NSPredicate(format: "title = %@ && desc = %@", feedItem?.title ?? "", feedItem?.desc ?? "")
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            return nil
        }
    }
    
    func searchForFavorites(with filter: String? = nil) -> [SavedMessages] {
        let fetchRequest = NSFetchRequest<SavedMessages>(entityName: "SavedMessages")
        
        if let searchFilter = filter {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR desc CONTAINS[cd] %@", searchFilter, searchFilter)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "savedDate", ascending: false)]
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results
        } catch {
            return []
        }
    }
    
    func clearFavorites() throws {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedMessages")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        try managedObjectContext.execute(deleteRequest)
    }
}
