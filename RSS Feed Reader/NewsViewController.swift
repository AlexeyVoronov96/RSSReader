//
//  NewsViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import SystemConfiguration

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var rssItems: [RSSItem]?
    var refreshControl: UIRefreshControl!
    var url: String?
    var name: String?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
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
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.init(red: 66.0/255.0, green: 139.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        UserDefaults.standard.setValue(url, forKey: "Link")
        
        if isInternetAvailable() == true{
            fetchData()
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
            refreshControl.tintColor = UIColor.white
            tableView.addSubview(refreshControl)
        } else {
            addSavedData()
        }
        
    }
    
    @objc func refresh(_ sender: Any) {
            fetchData()
            self.refreshControl.endRefreshing()
    }
    
    public func fetchData() {
        let feedParser = FeedParser()
        feedParser.parseFeed(url: self.url!) { (rssItems) in
            self.rssItems = rssItems
            OperationQueue.main.addOperation {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
    
    func addSavedData(){
        let data = UserDefaults.standard.value(forKey:self.url!) as? Data
        let decodedData = try? PropertyListDecoder().decode(Array<RSSItem>.self, from: data!)
        self.rssItems = decodedData
        OperationQueue.main.addOperation {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let rssItems = rssItems else {
            return 0
        }
        return rssItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        if let item = rssItems?[indexPath.item]{
            cell.item = item
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isInternetAvailable() == true{
            let webVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "web") as! WebViewController
            webVC.url = self.rssItems![indexPath.item].link
            webVC.name = self.name
            self.present(webVC, animated: true, completion: nil)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! NewsTableViewCell
            cell.selectionStyle = .none
            tableView.beginUpdates()
            cell.DescriptionLabel.numberOfLines = (cell.DescriptionLabel.numberOfLines == 0) ? 3 : 0
            tableView.endUpdates()
        }
    }
    
}
