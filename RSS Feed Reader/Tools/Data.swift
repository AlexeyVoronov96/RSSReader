//
//  ChannelsData.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 19/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Channels: Object {
    dynamic var name: String? = nil
    dynamic var link: String? = nil
    
    convenience init(name: String?,
                     link: String?) {
        self.init()
        self.name = name
        self.link = link
    }
    
}
