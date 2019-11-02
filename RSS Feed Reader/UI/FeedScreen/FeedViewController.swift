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
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = collectionView {
            let w = collectionView.frame.width - 16
            flowLayout.estimatedItemSize = CGSize(width: w, height: 100)
        }
        
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
        cell.delegate = self
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let link = feed?.messagesSorted[indexPath.row].link,
            let url = URL(string: link) else {
                return
        }
        let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        self.present(svc, animated: true, completion: nil)
    }
}

extension FeedViewController: FeedItemCellDelegate {
    func didTapOnMoreButton(_ cell: FeedItemCell) {
        let alertController = UIAlertController(title: cell.feedItem?.title ?? "",
                                                message: cell.feedItem?.desc ?? "",
                                                preferredStyle: .actionSheet)
        let searchedItem = CoreDataManager.shared.checkFavoriteItem(with: cell.feedItem)
        let title = searchedItem == nil ? "Add to favorites" : "Remove from favorites"
        alertController.addAction(UIAlertAction(title: title, style: .default, handler: { (_) in
            if let favoriteItem = searchedItem {
                CoreDataManager.shared.managedObjectContext.delete(favoriteItem)
            } else {
                SavedMessages.newMessage(from: cell.feedItem)
            }
            CoreDataManager.shared.saveContext()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
