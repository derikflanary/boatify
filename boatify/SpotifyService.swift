//
//  SpotifyService.swift
//  boatify
//
//  Created by Derik Flanary on 8/6/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import UIKit

struct SpotifyService {
    
    // MARK: - Properties
    
    static let kClientId = "08e656aa8c444173ab066eb4a3ca7bf7"
    let kCallbackURL = "boatify-login://callback"
    var player = SPTAudioStreamingController.sharedInstance()

    
    func updateIsPlaying() {
        guard let player = player else { return }
        player.setIsPlaying(!player.playbackState.isPlaying, callback: { error in
            if let error = error {
                print(error)
            }
        })
    }
    
    func trackProgress() -> Float {
        guard let player = player, let trackDuration = player.metadata.currentTrack?.duration else { return 0.0 }
        let percent = (player.playbackState.position) / (trackDuration)
        return Float(percent)
    }
    
    
    func set(volume: Double) {
        player?.setVolume(volume, callback: nil)
    }
    
    func advanceToNextTrack() {
        player?.skipNext { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func advanceToPreviousTrack() {
        player?.skipPrevious { error in
            if let error = error {
                print(error)
            }
        }
    }
    
}


