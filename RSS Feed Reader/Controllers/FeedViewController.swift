//
//  FeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import SafariServices

class FeedViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    static let feedController = FeedViewController()
    
    var rssItems: [RSSItem]?
    var feed: FeedsList?
    var imgs: [String] = []
    var refreshControl: UIRefreshControl!
    var url: String?, name: String?, toast: String?
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    func setTitle() {
        guard name == nil else {
            self.navigationItem.title = name
            return
        }
        self.navigationItem.title = "Feed list".localize()
    }
    
    func addLongPress() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer: )))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addFeed(_:)), name: NSNotification.Name(rawValue: "currentChannel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeFeed(_:)), name: NSNotification.Name(rawValue: "sendChannelStats"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteChannel(_:)), name: NSNotification.Name(rawValue: "deleteChannel"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        setTitle()
        addLongPress()
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = collectionView {
            let w = collectionView.frame.width - 16
            flowLayout.estimatedItemSize = CGSize(width: w, height: 0)
        }
    }
    
    @IBAction func openFavourites(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let fvc = storyboard.instantiateViewController(withIdentifier: "Favorites")
        present(fvc, animated: true, completion: nil)
    }
    
    @IBAction func openSlideInMenu(_ sender: Any) {
        ContainerViewController.containerController.sideMenuOpen = false
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: p)
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if let index = indexPath {
                AlertService.shareAlert(in: self, indexPath: index, message: message, feed: self.feed!)
            }
            return
        }
    }
    
    func setActivityIndicator() {
        collectionView.addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = CGPoint(x: collectionView.frame.width/2, y: 20)
        activityIndicator.startAnimating()
    }
    
    func addRefresh() {
        refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
    }
    
    @objc func refresh(_ sender: Any) {
        guard isInternetAvailable() else {
            self.refreshControl.endRefreshing()
            return
        }
        self.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.fetchData(feedChanged: false)
        })
    }
    
    @objc func addFeed(_ notification: NSNotification) {
        if let channel = notification.object {
            self.feed = (channel as! FeedsList)
        }
    }
    
    @objc func changeFeed(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            self.url = dict["link"] as? String
            self.navigationItem.title = dict["name"] as? String
            addRefresh()
            guard isInternetAvailable() else {
                self.addSavedData()
                return
            }
            self.setActivityIndicator()
            guard self.rssItems != nil else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.fetchData(feedChanged: true)
                })
                return
            }
            self.rssItems?.removeAll()
            UIView.transition(with: self.collectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.collectionView.reloadData()
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.fetchData(feedChanged: true)
            })
        }
    }
    
    @objc func deleteChannel(_ notification: NSNotification) {
        self.name = nil
        self.url = nil
        self.rssItems?.removeAll()
        self.setTitle()
        UIView.transition(with: self.collectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
    func addSavedData() {
        toast = "Connection error".localize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toast"), object: self.toast)
        NotificationCenter.default.post(name: NSNotification.Name("showToast"), object: nil)
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        self.collectionView.reloadData()
    }
    
    public func fetchData(feedChanged: Bool) {
        guard isInternetAvailable() else {
            refreshControl.endRefreshing()
            return
        }
        DispatchQueue.main.async {
            guard self.feed?.feed?.count != nil else { return }
            for message in self.feed!.feed! {
                CoreDataManager.sharedInstance.managedObjectContext.delete(message as! Feed)
            }
        }
        guard self.url != nil else { return }
        let feedParser = FeedParser()
        feedParser.feed = self.feed
        feedParser.parseFeed(url: self.url!) { (rssItems) in
            self.rssItems = rssItems
            self.imgs = feedParser.imgs
            OperationQueue.main.addOperation {
                if !feedChanged {
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                } else {
                    UIView.transition(with: self.collectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.collectionView.reloadData()
                    }, completion: nil)
                }
                self.activityIndicator.removeFromSuperview()
            }
        }
    }
    
}

extension FeedViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard isInternetAvailable() else {
            guard let feed = feed?.feed else {
                return 0
            }
            return feed.count
        }
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FeedCollectionViewCell
        guard isInternetAvailable() else {
            if let messageInCell = self.feed?.messagesSorted[indexPath.row] {
                cell.savedItem = messageInCell
            }
            cell.heightConstraint.constant = 0
            return cell
        }
            if imgs.count != rssItems?.count {
                imgs.append("")
            }
            if let item = rssItems?[indexPath.item] {
                cell.item = item
            }
            cell.heightConstraint.constant = (imgs[indexPath.row] == "") ? 0 : cell.newsImage.frame.width / 16 * 9
            if imgs[indexPath.row] != "" {
                cell.image = imgs[indexPath.row]
            }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentLink: String
        if rssItems?.isEmpty == false {
            currentLink = self.rssItems![indexPath.row].link
        } else {
            currentLink = (feed?.messagesSorted[indexPath.row].link)!
        }
        let svc = SFSafariViewController(url: NSURL(string: currentLink)! as URL)
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
