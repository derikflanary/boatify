//
//  PlaySelectedLocalTrack.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import AVFoundation

struct PlaySelectedLocalTrack: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let playlist = state.localMusicState.selectedPlaylist else { return }
        guard let selectedTrack = state.localMusicState.selectedTrack else { return }
        
        let player = state.localMusicState.player
        player.removeAllItems()
        
        var advanceToNext = true
        var tracks = playlist.items
        if case .on = state.localMusicState.shuffle {
            tracks.shuffled()
        }
        
        for item in tracks {
            guard let url = item.assetURL else { continue }
            let playerItem = AVPlayerItem(url: url)
            player.insert(playerItem, after: nil)
            if item != selectedTrack && advanceToNext {
                player.advanceToNextItem()
            } else if item == selectedTrack {
                advanceToNext = false
            }
        }
        
        player.volume = Float(state.recorderState.volume.min)
        player.play()
        core.fire(event: Playing(item: selectedTrack))
    }
    
}

