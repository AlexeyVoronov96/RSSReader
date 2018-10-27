//
//  AlertControllers.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 05/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AlertService {
    
    var message: SavedMessages?
    
    private init() {}
    
    static func addAlert(in vc: ChannelsViewController, completion: @escaping (String?, String?) -> Void) {
        let alertController = UIAlertController(title: "Add new channel".localize(), message: nil, preferredStyle: .alert)
        alertController.addTextField { (nameTextField) in
            nameTextField.placeholder = "Channel name".localize()
            nameTextField.clearButtonMode = .whileEditing
        }
        alertController.addTextField { (linkTextField) in
            linkTextField.placeholder = "Channel link".localize()
            linkTextField.keyboardType = UIKeyboardType.URL
            linkTextField.clearButtonMode = .whileEditing
        }
        
        let alertAction1 = UIAlertAction(title: "Add".localize(), style: .default) { (alert) in
            let newItem = alertController.textFields![0].text
            let newItem2 = alertController.textFields![1].text
            let name = newItem == "" ? nil : newItem
            let link = newItem2 == "" ? nil : newItem2
            completion(name, link)
        }
        let alertAction2 = UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil)
        
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func updateAlert(in vc: ChannelsViewController, channelsData: FeedsList, completion: @escaping (String?, String?) -> Void) {
        let alertController = UIAlertController(title: "Change channel".localize(), message: nil, preferredStyle: .alert)
        alertController.addTextField { (nameTextField) in
            nameTextField.text = (channelsData.name)
            nameTextField.placeholder = "Channel name".localize()
            nameTextField.clearButtonMode = .whileEditing
        }
        alertController.addTextField { (linkTextField) in
            linkTextField.text = (channelsData.link)
            linkTextField.placeholder = "Channel link".localize()
            linkTextField.keyboardType = UIKeyboardType.URL
            linkTextField.clearButtonMode = .whileEditing
        }
        
        let alertAction1 = UIAlertAction(title: "Change".localize(),
                                         style: .default) { (alert) in
            let newItem = alertController.textFields![0].text
            let newItem2 = alertController.textFields![1].text
            let name = newItem == "" ? nil : newItem
            let link = newItem2 == "" ? nil : newItem2
            completion(name, link)
        }
        let alertAction2 = UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil)
        
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func shareAlert(in vc: FeedViewController, indexPath: IndexPath, message: [SavedMessages]) {
        let currentItem = vc.rssItems![indexPath.row]
        let image = vc.imgs[indexPath.row]
        let cell = vc.collectionView.cellForItem(at: indexPath) as? FeedCollectionViewCell
        let alert = UIAlertController(title: currentItem.title, message: nil, preferredStyle: .actionSheet)
        if message.index(where: { ($0.title! == currentItem.title) && ($0.desc! == currentItem.description) && ($0.link! == currentItem.link) }) == nil {
            alert.addAction(UIAlertAction(title: "Add to favourites".localize(), style: .default, handler: { action in
                _ = SavedMessages.newMessage(title: currentItem.title, desc: currentItem.description, pubDate: currentItem.pubDate, link: currentItem.link, image: image)
                CoreDataManager.sharedInstance.saveContext()
            }))
        }
        alert.addAction(UIAlertAction(title: "Open in Safari".localize(), style: .default, handler: { action in
            UIApplication.shared.open(URL(string: currentItem.link)!)
            vc.activityIndicator.removeFromSuperview()
        }))
        alert.addAction(UIAlertAction(title: "Save message to Photos".localize(), style: .default, handler: { action in
            let image = cell?.captureView()
            UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
            vc.activityIndicator.removeFromSuperview()
        }))
        if image != "" {
            alert.addAction(UIAlertAction(title: "Save image".localize(), style: .default, handler: { action in
                    let img = cell?.newsImage.image
                    UIImageWriteToSavedPhotosAlbum(img!, self, nil, nil)
                    vc.activityIndicator.removeFromSuperview()
                }))
        }
        alert.addAction(UIAlertAction(title: "Copy".localize(), style: .default, handler: { action in
                let copiedItem = currentItem.title + "\n\n" + currentItem.description + "\n\n" + currentItem.link
                UIPasteboard.general.string = copiedItem
                vc.activityIndicator.removeFromSuperview()
        }))
        alert.addAction(UIAlertAction(title: "Share".localize(), style: .default, handler: { action in
            if image != "" {
                let img = cell?.newsImage.image
                let objectsToShare = [currentItem.title, "\n", currentItem.description, "\n", img as Any, "\n", currentItem.link]
                let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                          applicationActivities: nil)
                vc.activityIndicator.removeFromSuperview()
                vc.present(activityVC,
                           animated: true,
                           completion: nil)
            }
            else{
                let objectsToShare = [currentItem.title, "\n", currentItem.description, "\n", currentItem.link]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                vc.activityIndicator.removeFromSuperview()
                vc.present(activityVC, animated: true, completion: nil)
                                        }
           
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: { action in
            vc.activityIndicator.removeFromSuperview()
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func favoritesShareAlert(in vc: FavoritesCollectionViewController, channelsData: SavedMessages, indexPath: IndexPath) {
        let cell = vc.collectionView.cellForItem(at: indexPath) as? FavoritesCollectionViewCell
        let alert = UIAlertController(title: channelsData.title, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove from favourites".localize(), style: .destructive, handler: { action in
            CoreDataManager.sharedInstance.managedObjectContext.delete(channelsData)
            CoreDataManager.sharedInstance.saveContext()
            vc.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Open in Safari".localize(), style: .default, handler: { action in
            UIApplication.shared.open(URL(string: channelsData.link!)!)
        }))
        alert.addAction(UIAlertAction(title: "Save message to Photos".localize(), style: .default, handler: { action in
                let image = cell?.captureView()
                UIImageWriteToSavedPhotosAlbum(image!, self, nil, nil)
        }))
        if channelsData.image != "" {
            alert.addAction(UIAlertAction(title: "Save image".localize(), style: .default, handler: { action in
                let img = cell?.newsImage.image
                UIImageWriteToSavedPhotosAlbum(img!, self, nil, nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Copy".localize(), style: .default, handler: { action in
            let copiedItem = channelsData.title! + "\n\n" + channelsData.desc! + "\n\n" + channelsData.link!
            UIPasteboard.general.string = copiedItem
        }))
        alert.addAction(UIAlertAction(title: "Share".localize(), style: .default, handler: { action in
            if channelsData.image != "" {
                let img = cell?.newsImage.image
                let objectsToShare = [channelsData.title!, "\n", channelsData.desc!, "\n", img as Any, "\n", channelsData.link!]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                vc.present(activityVC, animated: true, completion: nil)
            }
            else{
                let objectsToShare = [channelsData.title!, "\n", channelsData.desc!, "\n", channelsData.link!]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                vc.present(activityVC, animated: true, completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: { action in
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func clearFavouritesAlert(in vc: FavoritesCollectionViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Clear favourites".localize(), style: .destructive, handler: {action in
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
            CoreDataManager.sharedInstance.saveContext()
            UIView.transition(with: vc.collectionView, duration: 1, options: .transitionCurlUp, animations: {
                vc.collectionView.reloadData()
            }, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: { action in
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
}
