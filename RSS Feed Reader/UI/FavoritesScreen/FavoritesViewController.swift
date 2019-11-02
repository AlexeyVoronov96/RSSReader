//
//  FavoritesViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 27/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import CoreData
import UIKit
import SafariServices

class FavoritesViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "FeedItemCell", bundle: nil),
                                forCellWithReuseIdentifier: "FeedItemCell")
        
        fetchAllFavorites()
        collectionView.alwaysBounceVertical = true
    }
    
    @IBAction func removeAllAction(_ sender: Any) {
        if favorites.isEmpty {
            return
        }
        
        let alertController = UIAlertController(title: "Are you sure?", message: "This will remove all favorite items", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] (_) in
            self?.removeAllFavorites()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func fetchAllFavorites() {
        CoreDataManager.shared.favoritesFetchedResultsController.delegate = self
        
        do{
            try CoreDataManager.shared.favoritesFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    func removeAllFavorites() {
        for item in favorites {
            CoreDataManager.shared.managedObjectContext.delete(item)
            CoreDataManager.shared.saveContext()
        }
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = CoreDataManager.shared.favoritesFetchedResultsController.sections else {
            return 0
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedItemCell", for: indexPath) as! FeedItemCell
        let favoriteItem = CoreDataManager.shared.favoritesFetchedResultsController.object(at: indexPath)
        cell.favoriteItem = favoriteItem
        cell.delegate = self
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FeedItemCell,
            let url = URL(string: cell.favoriteItem?.link ?? "") else {
            return
        }
        let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        self.present(svc, animated: true, completion: nil)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FeedItemCell else {
            return nil
        }
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let action = UIAction(title: "Remove from favorites", image: #imageLiteral(resourceName: "delete")) { (_) in
                guard let favoriteItem = cell.favoriteItem else {
                    return
                }
                CoreDataManager.shared.managedObjectContext.delete(favoriteItem)
                CoreDataManager.shared.saveContext()
            }
            return UIMenu(title: cell.feedItem?.title ?? "", image: #imageLiteral(resourceName: "delete"), children: [action])
        }
        return configuration
    }
}

extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                collectionView.insertItems(at: [indexPath])
            }
            break
            
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
            }
            break
            
        case .update:
            break
            
        case .move:
            if let indexPath = indexPath {
                collectionView.insertItems(at: [indexPath])
            }
            
            if let newIndexPath = newIndexPath {
                collectionView.insertItems(at: [newIndexPath])
            }
            break
        }
    }
}

extension FavoritesViewController: FeedItemCellDelegate {
    func didTapOnMoreButton(_ cell: FeedItemCell) {
        let alertController = UIAlertController(title: cell.favoriteItem?.title ?? "",
                                                message: cell.favoriteItem?.desc ?? "",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Remove from favorites", style: .default, handler: { (_) in
            guard let favoriteItem = cell.favoriteItem else {
                return
            }
            CoreDataManager.shared.managedObjectContext.delete(favoriteItem)
            CoreDataManager.shared.saveContext()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 100)
    }
}


