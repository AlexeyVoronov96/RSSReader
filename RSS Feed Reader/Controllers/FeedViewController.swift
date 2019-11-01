//
//  FeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import SafariServices

class FeedViewController: UICollectionViewController {
    
    static let shared = FeedViewController()
    
    var rssItems: [RSSItem]?
    var feed: FeedsList?
    var imgs: [String] = []
    var refreshControl: UIRefreshControl!
    var url: String?, name: String?
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        extendedLayoutIncludesOpaqueBars = true
        addObservers()
        setTitle()
        addLongPress()
        configureCellSize()
        completingImageLinks()
    }
    
    @IBAction func openFavourites(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fvc = storyboard.instantiateViewController(withIdentifier: "Favorites")
        present(fvc, animated: true, completion: nil)
    }
    
    @IBAction func openSlideInMenu(_ sender: Any) {
        ContainerViewController.shared.sideMenuOpen = false
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    final func addSavedData() {
        DispatchQueue.main.async {
//            ChannelsViewController.shared.makeToast(toast: "Connection error")
            self.collectionView.reloadData()
            self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    final func fetchData() {
//        guard isInternetAvailable() else {
//            refreshControl.endRefreshing()
//            return
//        }
        DispatchQueue.main.async {
            if self.feed?.feed?.count != 0 {
                for message in self.feed!.feed! {
                    CoreDataManager.shared.managedObjectContext.delete(message as! Feed)
                }
            }
        }
        guard self.url != nil else { return }
        let feedParser = FeedParser()
        feedParser.feed = self.feed
        feedParser.parseFeed(url: self.url!) { (rssItems, imgs) in
            self.rssItems = rssItems
            self.imgs = imgs
            OperationQueue.main.addOperation {
                self.refreshControl.endRefreshing()
                self.collectionView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard isInternetAvailable() else {
//            guard let feed = feed?.feed else {
//                return 0
//            }
//            return feed.count
//        }
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FeedCollectionViewCell
//        if isInternetAvailable() {
//            if let rssItems = rssItems {
//                cell.configureMessages(indexPath: indexPath, rssItems: rssItems)
//            }
//            cell.configureImages(indexPath: indexPath, imgs: imgs)
//        } else {
//            if let feed = feed {
//                cell.configureSavedMessages(indexPath: indexPath, feed: feed)
//            }
//        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentLink: String
        if rssItems?.isEmpty == false {
            currentLink = self.rssItems![indexPath.row].link
        } else {
            currentLink = (feed?.messagesSorted[indexPath.row].link)!
        }
        let svc = SFSafariViewController(url: NSURL(string: currentLink)! as URL, entersReaderIfAvailable: true)
        svc.preferredBarTintColor = Colors.sharedInstance.blue
        svc.preferredControlTintColor = Colors.sharedInstance.white
        self.present(svc, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? FeedCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? FeedCollectionViewCell {
                cell.contentView.backgroundColor = .clear
            }
        }
    }
    
}
