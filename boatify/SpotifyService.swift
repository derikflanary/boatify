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

    
    func trackProgress() -> Float {
        if player != nil && player?.metadata != nil {
            guard let player = player, let trackDuration = player.metadata.currentTrack?.duration else { return 0.0 }
            let percent = (player.playbackState.position) / (trackDuration)
            return Float(percent)
        }
        return Float(0.0)
    }
    
    
    func set(volume: Double) {
        player?.setVolume(volume, callback: nil)
    }
    
    func stopPlayer() {
        do {
            try player?.stop()
        } catch {
            print(error)
        }
    }
    
    func currentTrackData() -> SPTPlaybackTrack? {
        guard let player = player else { return nil }
        return player.metadata.currentTrack
    }
    
}


