//
//  Model.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation

var ToAddLinks: [[String: Any]] {
    set {
        UserDefaults.standard.set(newValue, forKey: "Channels")
        UserDefaults.standard.synchronize()
    }
    get{
        if let array = UserDefaults.standard.array(forKey: "Channels") as? [[String: Any]] {
            return array
        } else {
            return []
        }
    }
}

func renameItem(nameItem: String, linkItem: String, at index: Int) {
    ToAddLinks.remove(at: index)
    ToAddLinks.insert(["Name": nameItem, "Link": linkItem], at: index)
}

func addItem(nameItem: String, linkItem: String) {
    ToAddLinks.append(["Name": nameItem, "Link": linkItem])
}

func removeItem(at index: Int) {
    ToAddLinks.remove(at: index)
}

func moveItem(fromIndex: Int, toIndex: Int) {
    let from = ToAddLinks[fromIndex]
    ToAddLinks.remove(at: fromIndex)
    ToAddLinks.insert(from, at:toIndex)
}

