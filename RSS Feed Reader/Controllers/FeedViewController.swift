//
//  FeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import RealmSwift
import Toast_Swift
import QuickPersist

class FeedViewController: UICollectionViewController, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    
    private var rssItems: [RSSItem]?
    var refreshControl: UIRefreshControl!
    var url: String?
    var name: String?
    
    var realm: Realm!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        if name == nil{
            self.navigationItem.title = "Лента новостей"
        } else {
            self.navigationItem.title = name
        }
        if isInternetAvailable() == true{
            self.view.makeToastActivity(.center)
            fetchData()
            refreshControl = UIRefreshControl()
            collectionView.addSubview(refreshControl)
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            refreshControl.tintColor = UIColor.white
        } else {
            var style = ToastStyle()
            style.messageColor = UIColor.init(red: 66/255, green: 139/255, blue: 202/255, alpha: 1)
            style.backgroundColor = .white
            self.view.makeToast("Отсутствует подключение к интернету", position: .center, style: style)
        }
        
    }
    
    
    
    @objc func refresh(_ sender: Any) {
        fetchData()
    }
    
    public func fetchData() {
        let feedParser = FeedParser()
        feedParser.parseFeed(url: self.url!) { (rssItems) in
            self.rssItems = rssItems
            OperationQueue.main.addOperation {
                self.view.hideToastActivity()
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FeedCollectionViewCell
        if let item = rssItems?[indexPath.item]{
            cell.item = item
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (view.frame.width - 16), height: 170)
        return size
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMore" {
            if let cell = sender as? FeedCollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
                if isInternetAvailable() == true{
                    let destination = segue.destination as! WebViewController
                    let currentItem = rssItems![indexPath.row]
                    destination.url = currentItem.link
                    print(currentItem.link)
                    destination.name = currentItem.title
                }
            }
        }
    }
    
}
