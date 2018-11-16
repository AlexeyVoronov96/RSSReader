//
//  ChannelsViewControllerExtension.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 16/11/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation
import UIKit

extension ChannelsViewController {
    
    func makeToast(toast: String) {
        let toastText = toast.localize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toast"), object: toastText)
        NotificationCenter.default.post(name: NSNotification.Name("showToast"), object: nil)
    }
    
}
