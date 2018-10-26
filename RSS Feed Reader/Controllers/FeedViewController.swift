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
    var feed: FeedsList?
    var imgs: [String] = []
    var refreshControl: UIRefreshControl!
    var url: String?, name: String?
    var height: Int = 0
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.addFolder(_:)),
                                               name: NSNotification.Name(rawValue: "currentChannel"),
                                               object: nil)
        self.url = UserDefaults.standard.string(forKey: "link")
        self.name = UserDefaults.standard.string(forKey: "name")
        self.extendedLayoutIncludesOpaqueBars = true
        if self.url != "" {
            setTitle()
            loadFeed()
        }
        addLongPress()
        setActivityIndicator()
        if self.url == nil {
            NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                            object: nil)
        } else {
            ContainerViewController().sideMenuOpen = false
        }

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
    
    @IBAction func openSlideInMenu(_ sender: Any) {
        ContainerViewController().sideMenuOpen = false
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"),
                                        object: nil)
    }
    
    func setTitle() {
        if name == nil {
            self.navigationItem.title = "Лента новостей"
        } else {
            self.navigationItem.title = name
        }
    }
    
    func setActivityIndicator() {
        collectionView.addSubview(activityIndicator)
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        activityIndicator.startAnimating()
    }
    
    func loadFeed() {
        if isInternetAvailable() == true {
            fetchData(feedChanged: true)
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
    
    @objc func addFolder(_ notification: NSNotification) {
        if let channel = notification.object {
            self.feed = (channel as! FeedsList)
            print(self.feed!)
        }
    }
    
    @objc func changeFeed(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if self.url != nil {
                if self.url != dict["link"] as? String {
                    self.setActivityIndicator()
                    self.url = dict["link"] as? String
                    self.navigationItem.title = dict["name"] as? String
                    self.rssItems?.removeAll()
                    UIView.transition(with: self.collectionView, duration: 1, options: .transitionCurlUp, animations: {
                        //Do the data reload here
                        self.collectionView.reloadData()
                    }, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),
                                                  execute: {
                                                    self.fetchData(feedChanged: true)
                    })
                }
            } else {
                self.setActivityIndicator()
                self.url = dict["link"] as? String
                self.navigationItem.title = dict["name"] as? String
                self.fetchData(feedChanged: true)
            }
        }
    }
    
    @objc func refresh(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1),
                                      execute: {
            self.fetchData(feedChanged: false)
        })
    }
    
    public func fetchData(feedChanged: Bool) {
        let feedParser = FeedParser()
        if self.url != nil {
            feedParser.feed = self.feed
            feedParser.parseFeed(url: self.url!) { (rssItems) in
                self.rssItems = rssItems
                self.imgs = feedParser.imgs
                OperationQueue.main.addOperation {
                    if feedChanged == false {
                            self.collectionView.reloadData()
                    } else {
                        UIView.transition(with: self.collectionView, duration: 1, options: .transitionCurlDown, animations: {
                            //Do the data reload here
                            self.collectionView.reloadData()
                        }, completion: nil)
                    }
                    self.activityIndicator.removeFromSuperview()
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
        if isInternetAvailable() == true {
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
        } else {
            if feed!.feed!.count != 0 {
            return feed!.feed!.count
            } else {
                return 0
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                      for: indexPath) as! FeedCollectionViewCell
        if isInternetAvailable() == true {
            if imgs.count != rssItems?.count {
                imgs.append("")
            }
            if let item = rssItems?[indexPath.item] {
                cell.item = item
            }
            if imgs[indexPath.row] != "" {
                let url = URL(string: imgs[indexPath.row])!
                cell.newsImage.kf.indicatorType = .activity
                cell.newsImage.kf.setImage(with: url)
                cell.heightConstraint.constant = cell.newsImage.frame.width / 16 * 9
            } else {
               cell.heightConstraint.constant = 0
            }
        } else {
            let messageInCell = self.feed!.messagesSorted[indexPath.row]
            print(messageInCell)
            cell.heightConstraint.constant = 0
            cell.titleLabel.text = messageInCell.title
            cell.descriptionLabel.text = messageInCell.desc
            cell.dateLabel.text = messageInCell.pubDate
        }
        return cell
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

extension UIView {
    
    // Convert a uiview to uiimage
    func captureView() -> UIImage {
        // Gradually increase the number for high resolution.
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, scale)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image:UIImage  = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}


