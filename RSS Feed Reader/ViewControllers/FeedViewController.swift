//
//  FeedViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 29/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let kCellHeight : CGFloat = 100
    let kLineSpacing : CGFloat = 10
    let kInset : CGFloat = 10
    
    private var rssItems: [RSSItem]?
    private var imgs: [AnyObject] = []
    var refreshControl: UIRefreshControl!
    var url: String?
    var name: String?
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        if name == ""{
            navigationBar.topItem?.title = "News Feed"
        } else {
            navigationBar.topItem?.title = name
        }

        UserDefaults.standard.setValue(url, forKey: "Link")
        
        if isInternetAvailable() == true{
            fetchData()
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            refreshControl.tintColor = UIColor.white
            collectionView.addSubview(refreshControl)
        } else {
            addSavedData()
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
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func addSavedData(){
        let data = UserDefaults.standard.value(forKey:self.url!) as? Data
        let decodedData = try? PropertyListDecoder().decode(Array<RSSItem>.self, from: data!)
        self.rssItems = decodedData
        OperationQueue.main.addOperation {
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FeedCollectionViewCell
        if let item = rssItems?[indexPath.item]{
            cell.item = item
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (view.frame.width - 16), height: 228)
        return size
    }

    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if isInternetAvailable() == true{
            let webVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "web") as! WebViewController
            webVC.url = self.rssItems![indexPath.item].link
            webVC.name = self.rssItems![indexPath.item].title
            self.present(webVC, animated: true, completion: nil)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (UIScreen.main.bounds.width - 2*kInset - kLineSpacing)/2, height: kCellHeight)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return kLineSpacing
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: kInset, left: kInset, bottom: kInset, right: kInset)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
}

extension FeedViewController : UICollectionViewDelegateFlowLayout
{
    
}

