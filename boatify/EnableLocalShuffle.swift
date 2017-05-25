//
//  EnableLocalShuffle.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import AVFoundation

struct EnableLocalShuffle: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Updated(item: Shuffle.on))
        
        guard let playlist = state.localMusicState.selectedPlaylist else { return }
        guard let currentTrack = state.localMusicState.currentTrack else { return }
        let player = state.localMusicState.player
        
        var tracks = playlist.items
        tracks.shuffled()
        for track in tracks {
            if currentTrack != track {
                guard let url = track.assetURL, let currentUrl = currentTrack.assetURL else { continue }
                let playerItem = AVPlayerItem(url: url)
                player.remove(playerItem)
                let currentITem = AVPlayerItem(url: currentUrl)
                player.insert(playerItem, after: currentITem)
            }
        }
    }
    
}

