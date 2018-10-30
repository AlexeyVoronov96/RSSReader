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
    }
    
    @IBAction func doneAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeAllAction(_ sender: Any) {
        if message.count > 0 {
            AlertService.clearFavouritesAlert(in: self)
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
                let currentMessage = message[index.row]
                AlertService.favoritesShareAlert(in: self, channelsData: currentMessage, indexPath: index)
            }
            return
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentItem = message[indexPath.row]
        let svc = SFSafariViewController(url: NSURL(string: currentItem.link!)! as URL)
        svc.preferredBarTintColor = Colors.color.blue
        svc.preferredControlTintColor = Colors.color.white
        self.present(svc, animated: true, completion: nil)
    }

}
