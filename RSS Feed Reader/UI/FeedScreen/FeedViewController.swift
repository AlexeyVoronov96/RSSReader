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
    
    var feed: Feed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreen()
    }
    
    private func setupScreen() {
        feed = feedService.selectedFeed
        fetchData()
        
        title = feed?.name
        
        collectionView.register(UINib(nibName: "FeedItemCell", bundle: nil),
                                forCellWithReuseIdentifier: "FeedItemCell")
    }
    
    private func fetchData() {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedItemCell.cellId, for: indexPath) as! FeedItemCell
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
            if let favoriteItem = CoreDataManager.shared.checkFavoriteItem(with: cell.feedItem) {
                actions.append(UIAction(title: "Remove from favorites".localize(), image: UIImage(systemName: "heart.slash.fill"), attributes: .destructive) { (_) in
                    CoreDataManager.shared.managedObjectContext.delete(favoriteItem)
                    CoreDataManager.shared.saveContext()
                })
            } else {
                actions.append(UIAction(title: "Add to favorites".localize(), image: UIImage(systemName: "heart")) { (_) in
                    FavoriteMessage.newMessage(from: cell.feedItem)
                    CoreDataManager.shared.saveContext()
                })
            }
            
            if let url = URL(string: cell.feedItem?.link ?? ""),
                UIApplication.shared.canOpenURL(url) {
                actions.append(UIAction(title: "Open in Safari".localize(), image: UIImage(systemName: "safari")) { (_) in
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
            
            return UIMenu(title: cell.feedItem?.title ?? "", children: actions)
        }
        return configuration
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 100)
    }
}
