//
//  FavoritesCollectionViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 27/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import SafariServices
import Kingfisher
import CoreData

class FavoritesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var messages: SavedMessages?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = collectionView {
            let w = collectionView.frame.width - 16
            flowLayout.estimatedItemSize = CGSize(width: w, height: 200)
        }
        
        addLongPress()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }
    
    @IBAction func removeAllAction(_ sender: Any) {
        self.deleteAllData()
        CoreDataManager.sharedInstance.saveContext()
        self.collectionView.reloadData()
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
                let currentMessage = message[index.row]
                AlertService.favoritesShareAlert(in: self, channelsData: currentMessage, indexPath: index)
            }
            return
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if message.count != 0 {
            return message.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FavoritesCollectionViewCell
        let currentMessage = message[indexPath.row]
        if currentMessage.image == "" {
            cell.heightConstraint.constant = 0
        } else {
            let url = URL(string: currentMessage.image!)!
            cell.newsImage.kf.indicatorType = .activity
            cell.newsImage.kf.setImage(with: url)
            cell.heightConstraint.constant = cell.newsImage.frame.width / 16 * 9
        }
        
        cell.titleLabel.text = currentMessage.title
        cell.descriptionLabel.text = currentMessage.desc
        cell.dateLabel.text = currentMessage.pubDate
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentItem = message[indexPath.row]
        let svc = SFSafariViewController(url: NSURL(string: currentItem.link!)! as URL)
        svc.preferredBarTintColor = Colors().blue
        svc.preferredControlTintColor = Colors().white
        self.present(svc, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    func deleteAllData()
    {
        let fetchRequest = NSFetchRequest<SavedMessages>(entityName: "SavedMessages")
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try CoreDataManager.sharedInstance.managedObjectContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                CoreDataManager.sharedInstance.managedObjectContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data error : \(error) \(error.userInfo)")
        }
    }

}
