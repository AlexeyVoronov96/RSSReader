//
//  FeedsListViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import CoreData
import UIKit

class FeedsListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllFeeds()
    }
    
    func fetchAllFeeds() {
        CoreDataManager.shared.fetchedResultsController.delegate = self
        
        do{
            try CoreDataManager.shared.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
}

extension FeedsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeedCell,
            let feed = cell.feed else {
                return []
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete".localize()) { (action, indexPath) in
            CoreDataManager.shared.managedObjectContext.delete(feed)
            CoreDataManager.shared.saveContext()
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension FeedsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = CoreDataManager.shared.fetchedResultsController.sections else {
            return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let feed = CoreDataManager.shared.fetchedResultsController.object(at: indexPath)
        cell.feed = feed
        return cell
    }
}

extension FeedsListViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
    
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
        if let indexPath = newIndexPath {
            tableView.insertRows(at: [indexPath], with: .fade)
        }
        break
        
    case .delete:
        if let indexPath = indexPath {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        break
        
    case .update:
        break
        
    case .move:
        if let indexPath = indexPath {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        if let newIndexPath = newIndexPath {
            tableView.insertRows(at: [newIndexPath], with: .fade)
        }
        break
  }
}
  
  /*The last delegate call*/
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    /*finally balance beginUpdates with endupdates*/
    tableView.endUpdates()
  }
}
