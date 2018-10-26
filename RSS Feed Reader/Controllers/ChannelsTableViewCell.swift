//
//  ChannelsTableViewCell.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 20/09/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import UIKit

class ChannelsTableViewCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLink: UILabel!
    
    func configure(with currentChannel: FeedsList) {
        if currentChannel.name == nil{
            labelName.text = "Безымянный канал"
        } else {
            labelName.text = currentChannel.name
        }
        labelLink.text = currentChannel.link
    }
    
}
