//
//  FavoritesCollectionViewController.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 27/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import SafariServices

class FavoritesCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = collectionView {
            let w = collectionView.frame.width - 16
            flowLayout.estimatedItemSize = CGSize(width: w, height: 100)
        }
        addLongPress()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeAllAction(_ sender: Any) {
        guard message.count != 0 else { return }
        AlertService.clearFavouritesAlert(in: self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard message.count != 0 else { return 0 }
        return message.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FavoritesCollectionViewCell
        cell.configureMessage(indexPath: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentItem = message[indexPath.row]
        let svc = SFSafariViewController(url: NSURL(string: currentItem.link!)! as URL, entersReaderIfAvailable: true)
        svc.preferredBarTintColor = Colors.sharedInstance.blue
        svc.preferredControlTintColor = Colors.sharedInstance.white
        self.present(svc, animated: true, completion: nil)
    }
    
}

extension FavoritesCollectionViewController: UIGestureRecognizerDelegate {
    
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
    
}
