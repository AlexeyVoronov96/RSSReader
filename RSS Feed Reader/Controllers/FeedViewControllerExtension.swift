//
//  FeedViewControllerExtension.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 16/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation
import UIKit

extension FeedViewController: UIGestureRecognizerDelegate {
    
    func addLongPress() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer: )))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        collectionView.addGestureRecognizer(lpgr)
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
    
}

extension FeedViewController {
    
    func configureCellSize() {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = collectionView {
            let w = collectionView.frame.width - 16
            flowLayout.estimatedItemSize = CGSize(width: w, height: 100)
        }
    }
    
    func completingImageLinks() {
        if imgs.count != rssItems?.count {
            imgs.append("")
        }
    }
    
    func setTitle() {
        guard name == nil else {
            self.navigationItem.title = name
            return
        }
        navigationItem.title = "Feed list".localize()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.addFeed(_:)), name: NSNotification.Name(rawValue: "currentChannel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeFeed(_:)), name: NSNotification.Name(rawValue: "sendChannelStats"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deleteChannel(_:)), name: NSNotification.Name(rawValue: "deleteChannel"), object: nil)
    }
    
    func setActivityIndicator() {
        collectionView.addSubview(activityIndicator)
        activityIndicator.style = .white
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
            self.fetchData()
        })
    }
    
    @objc func addFeed(_ notification: NSNotification) {
        if let channel = notification.object {
            self.feed = (channel as! FeedsList)
        }
    }
    
    @objc func changeFeed(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            url = dict["link"] as? String
            navigationItem.title = dict["name"] as? String
            addRefresh()
            guard isInternetAvailable() else {
                self.addSavedData()
                return
            }
            setActivityIndicator()
            rssItems?.removeAll()
            collectionView.reloadData()
            fetchData()
        }
    }
    
    @objc func deleteChannel(_ notification: NSNotification) {
        name = nil
        url = nil
        rssItems?.removeAll()
        setTitle()
        collectionView.reloadData()
    }
    
}
