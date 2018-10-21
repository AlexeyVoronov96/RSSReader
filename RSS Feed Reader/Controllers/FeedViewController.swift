//
//  FeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import Toast_Swift
import SafariServices
import Kingfisher

class FeedViewController: UICollectionViewController, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    
    var rssItems: [RSSItem]?
    var imgs: [String] = []
    var refreshControl: UIRefreshControl!
    var url: String?, name: String?
    var height: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.url = UserDefaults.standard.string(forKey: "link")
        self.name = UserDefaults.standard.string(forKey: "name")
        self.extendedLayoutIncludesOpaqueBars = true
        setTitle()
        loadFeed()
        addLongPress()
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                        object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.changeFeed(_:)),
                                               name: NSNotification.Name(rawValue: "notificationName"),
                                               object: nil)
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = collectionView {
            let w = collectionView.frame.width - 16
            flowLayout.estimatedItemSize = CGSize(width: w, height: 200)
        }
    }
    
    func setTitle() {
        if name == nil {
            self.navigationItem.title = "Лента новостей"
        } else {
            self.navigationItem.title = name
        }
    }
    
    func loadFeed() {
        if isInternetAvailable() == true {
            fetchData()
            refreshControl = UIRefreshControl()
            collectionView.refreshControl = refreshControl
            refreshControl.addTarget(self,
                                     action: #selector(refresh),
                                     for: .valueChanged)
            refreshControl.tintColor = UIColor.white
        } else {
            self.view.makeToast("Подключение остутствует",
                                duration: 3.0,
                                position: .bottom)
        }
    }
    
    @objc func changeFeed(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            self.url = dict["link"] as? String
            self.navigationItem.title = dict["name"] as? String
            self.fetchData()
            self.collectionView.setContentOffset(CGPoint(x: 0, y: -115),
                                                 animated: true)
        }
    }
    
    @objc func refresh(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),
                                      execute: {
            self.fetchData()
        })
    }
    
    public func fetchData() {
        let feedParser = FeedParser()
        if self.url != nil {
            self.rssItems?.removeAll()
            collectionView.reloadData()
            feedParser.parseFeed(url: self.url!) { (rssItems) in
                self.rssItems = rssItems
                self.imgs = feedParser.imgs
                OperationQueue.main.addOperation {
                    self.collectionView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func addLongPress() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureRecognizer: )))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: p)
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if let index = indexPath {
                AlertService.shareAlert(in: self,
                                        indexPath: index)
            }
            return
        }
    }
    
    public func addSavedData() {
        OperationQueue.main.addOperation {
            
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! FeedCollectionViewCell
        if imgs.count != rssItems?.count {
            imgs.append("")
        }
        if let item = rssItems?[indexPath.item] {
            cell.item = item
        }
        if imgs[indexPath.row] != "" {
        cell.heightConstraint.constant = cell.newsImage.frame.width / 16 * 9
        let url = URL(string: imgs[indexPath.row] )!
        cell.newsImage.kf.indicatorType = .activity
        cell.newsImage.kf.setImage(with: url,
                                   options: [.forceRefresh])
        } else {
           cell.heightConstraint.constant = 0
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8,
                                           y: 0.8)
        UIView.animate(withDuration: 0.25) {
            cell.transform = CGAffineTransform(scaleX: 1,
                                               y: 1)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let currentItem = self.rssItems![indexPath.row]
        let svc = SFSafariViewController(url: NSURL(string: currentItem.link)! as URL)
        svc.preferredBarTintColor = Colors().blue
        svc.preferredControlTintColor = Colors().white
        self.present(svc,
                     animated: true,
                     completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) {
            if let cell = collectionView.cellForItem(at: indexPath) as? FeedCollectionViewCell {
                cell.contentView.backgroundColor = UIColor(red: 0.85,
                                                           green: 0.85,
                                                           blue: 0.85,
                                                           alpha: 1)
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
    
    func takeScreenShot(scene: FeedCollectionViewCell) {
        let bounds = scene.bounds
        UIGraphicsBeginImageContext(bounds.size)
        scene.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
}

extension String {
    
    var utfData: Data? {
        return self.data(using: .utf8)
    }
    
    var attributedHtmlString: NSAttributedString? {
        guard let data = self.utfData else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,
                                          options: [
                                            .documentType: NSAttributedString.DocumentType.html,
                                            .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
