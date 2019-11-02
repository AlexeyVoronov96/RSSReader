//
//  AudioManager.swift
//  RSS Feed Reader
//
//  Created by Алексей Воронов on 30/10/2018.
//  Copyright © 2018 Алексей Воронов. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioManager {

    var player: AVPlayer?
    
    func playAudio() {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "refresh", ofType: "mp3")!)
        player = AVPlayer(url: url)
        player?.play()
    }
    
}
