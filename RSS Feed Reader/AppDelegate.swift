//
//  AppDelegate.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().shadowImage = UIImage()
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addFeedViewController = storyboard.instantiateViewController(identifier: "AddFeedViewController")
        switch shortcutItem.type {
        case "AlexeyVoronov.RSS-Feed-Reader.AddFeed":
            window?.rootViewController?.present(addFeedViewController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
}


