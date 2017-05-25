//
//  PlayLocalSelectedPlaylist.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import AVFoundation

struct PlayLocalSelectedPlaylist: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let playlist = state.localMusicState.selectedPlaylist else { return }
        guard playlist.items.count > 0 else { return }
        
        let player = state.localMusicState.player
        player.removeAllItems()
        
        var tracks = playlist.items
        if case .on = state.localMusicState.shuffle {
            tracks.shuffled()
        }
        
        for item in tracks {
            guard let url = item.assetURL else { continue }
            let playerItem = AVPlayerItem(url: url)
            player.insert(playerItem, after: nil)
        }
        
        player.volume = Float(state.recorderState.volume.min)
        player.play()
        guard let firstSong = playlist.items.first else { return }
        core.fire(event: Playing(item: firstSong))
        
        guard let audioRecorder = state.recorderState.audioRecorder else { return }
        if !audioRecorder.isRecording {
            core.fire(event: RecordingRequested())
        }
    }
    
}
