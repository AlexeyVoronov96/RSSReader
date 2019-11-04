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
    
    private let addFeedService = AddFeedService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllFeeds()
    }
    
    func fetchAllFeeds() {
        CoreDataManager.shared.feedsListFetchedResultsController.delegate = self
        
        do{
            try CoreDataManager.shared.feedsListFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
}

extension FeedsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeedCell else {
            return
        }
        FeedService.shared.selectedFeed = cell.feed
        performSegue(withIdentifier: "OpenFeed", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? FeedCell,
            let feed = cell.feed else {
            return nil
        }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let updateAction = UIAction(title: "Update".localize(), image: UIImage(systemName: "pencil")) { [weak self] (_) in
                self?.addFeedService.feed = feed
                self?.performSegue(withIdentifier: "OpenFeedEditor", sender: self)
            }
            
            let deleteAction = UIAction(title: "Remove".localize(), image: UIImage(systemName: "trash.fill")) { (_) in
                CoreDataManager.shared.managedObjectContext.delete(feed)
                CoreDataManager.shared.saveContext()
            }
            
            return UIMenu(title: feed.name ?? "", image: nil, children: [updateAction, deleteAction])
        }
        
        return configuration
    }
}

extension FeedsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = CoreDataManager.shared.feedsListFetchedResultsController.sections else {
            return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        let feed = CoreDataManager.shared.feedsListFetchedResultsController.object(at: indexPath)
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
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
