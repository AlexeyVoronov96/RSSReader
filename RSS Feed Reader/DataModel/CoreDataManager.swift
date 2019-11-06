//
//  CoreDataManager.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 25/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import CoreData

var favorites: [FavoriteMessage] {
    let request = NSFetchRequest<FavoriteMessage>(entityName: "FavoriteMessage")
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
    
    lazy var feedsListFetchedResultsController: NSFetchedResultsController<Feed> = {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Feed>(entityName: "Feed")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<Feed>(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
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
        let fetchRequest = NSFetchRequest<FeedMessage>(entityName: "FeedMessage")
        fetchRequest.predicate = NSPredicate(format: "title = %@ && desc = %@", title, description)
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            return false
        }
    }
    
    func checkFavoriteItem(with feedItem: FeedMessage?) -> FavoriteMessage? {
        let fetchRequest = NSFetchRequest<FavoriteMessage>(entityName: "FavoriteMessage")
        fetchRequest.predicate = NSPredicate(format: "title = %@ && desc = %@", feedItem?.title ?? "", feedItem?.desc ?? "")
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results.first
        } catch {
            return nil
        }
    }
    
    func searchForFavorites(with filter: String? = nil) -> [FavoriteMessage] {
        let fetchRequest = NSFetchRequest<FavoriteMessage>(entityName: "FavoriteMessage")
        
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
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMessage")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        try managedObjectContext.execute(deleteRequest)
    }
}
