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
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    var searchFilter: String?
    
    var messages: [FavoriteMessage] {
        if searchController.isActive, !(searchFilter ?? "").isEmpty {
            return CoreDataManager.shared.searchForFavorites(with: searchFilter)
        }
        return favorites
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "FeedItemCell", bundle: nil),
                                forCellWithReuseIdentifier: "FeedItemCell")
        
        collectionView.alwaysBounceVertical = true
        
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
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
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search".localize()
        searchController.searchBar.tintColor = #colorLiteral(red: 0.9254901961, green: 0.1882352941, blue: 0.3882352941, alpha: 1)
        navigationItem.searchController = searchController
    }
    
    func removeAllFavorites() {
        do {
            try CoreDataManager.shared.clearFavorites()
            collectionView.reloadSections([0])
        } catch {
            showError(with: error.localizedDescription)
        }
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedItemCell.cellId, for: indexPath) as! FeedItemCell
        let favoriteItem = messages[indexPath.row]
        cell.favoriteItem = favoriteItem
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FeedItemCell,
            let url = URL(string: cell.favoriteItem?.link ?? "") else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = #colorLiteral(red: 0.9254901961, green: 0.1882352941, blue: 0.3882352941, alpha: 1)
        present(safariViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FeedItemCell else {
            return .none
        }
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            var actions: [UIAction] = []
            if let favoriteItem = cell.favoriteItem {
                actions.append(UIAction(title: "Remove from favorites", image: UIImage(systemName: "heart.slash.fill"), attributes: .destructive) { [weak self] (_) in
                    CoreDataManager.shared.managedObjectContext.delete(favoriteItem)
                    CoreDataManager.shared.saveContext()
                    self?.collectionView.deleteItems(at: [indexPath])
                })
            }
            
            if let url = URL(string: cell.favoriteItem?.link ?? ""),
            UIApplication.shared.canOpenURL(url) {
                actions.append(UIAction(title: "Open in safari".localize(), image: UIImage(systemName: "safari")) { (_) in
                    UIApplication.shared.open(url)
                })
            }
            
            actions.append(UIAction(title: "Share".localize(), image: UIImage(systemName: "square.and.arrow.up")) { [weak self] (_) in
                var activityItems: [Any] = [cell.feedItem?.title ?? "", cell.feedItem?.desc ?? ""]
                if let image = cell.image {
                    activityItems.append(image)
                }
                let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
                self?.present(activityController, animated: true, completion: nil)
            })
            
            return UIMenu(title: cell.favoriteItem?.title ?? "", children: actions)
        }
        return configuration
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 100)
    }
}

extension FavoritesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchFilter = searchController.searchBar.text
        collectionView.reloadSections([0])
    }
}
