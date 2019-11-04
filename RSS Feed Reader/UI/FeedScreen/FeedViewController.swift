//
//  FeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import SafariServices

class FeedViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!
    
    private let dataFetcher = DataFetcher()
    private let feedService = FeedService.shared
    
    var feed: FeedsList?
    var refreshControl: UIRefreshControl!
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feed = feedService.selectedFeed
        fetchData()
        
        title = feed?.name
        
        collectionView.register(UINib(nibName: "FeedItemCell", bundle: nil),
                                forCellWithReuseIdentifier: "FeedItemCell")
    }
    
    func fetchData() {
        guard let url = feed?.link else {
            return
        }
        dataFetcher.feed = feed
        dataFetcher.getFeed(with: url) { [weak self] (error) in
            if let error = error {
                self?.showError(with: error.localizedDescription)
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed?.messagesSorted.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedItemCell", for: indexPath) as! FeedItemCell
        cell.feedItem = feed?.messagesSorted[indexPath.row]
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let link = feed?.messagesSorted[indexPath.row].link,
            let url = URL(string: link) else {
                return
        }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FeedItemCell else {
            return nil
        }
        let searchedItem = CoreDataManager.shared.checkFavoriteItem(with: cell.feedItem)
        let title = searchedItem == nil ? "Add to favorites" : "Remove from favorites"
        let image = searchedItem == nil ? #imageLiteral(resourceName: "favorites") : #imageLiteral(resourceName: "delete")
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let favoritesAction = UIAction(title: title, image: image) { (_) in
                if let favoriteItem = searchedItem {
                    CoreDataManager.shared.managedObjectContext.delete(favoriteItem)
                } else {
                    SavedMessages.newMessage(from: cell.feedItem)
                }
                CoreDataManager.shared.saveContext()
            }
            
            let safariAction = UIAction(title: "Open in safari".localize(), image: UIImage(systemName: "safari")) { (_) in
                guard let url = URL(string: cell.feedItem?.link ?? ""),
                    UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url)
            }
            
            let shareAction = UIAction(title: "Share".localize(), image: UIImage(systemName: "square.and.arrow.up")) { [weak self] (_) in
                var activityItems: [Any] = [cell.feedItem?.title ?? "", cell.feedItem?.desc ?? ""]
                if let image = cell.image {
                    activityItems.append(image)
                }
                let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
                self?.present(activityController, animated: true, completion: nil)
            }
            
            return UIMenu(title: cell.feedItem?.title ?? "", image: #imageLiteral(resourceName: "delete"), children: [favoritesAction, safariAction, shareAction])
        }
        return configuration
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 100)
    }
}
