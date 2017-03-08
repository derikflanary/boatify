//
//  UpdateLocalPlayPause.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct UpdateLocalPlayPause: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        switch state.localMusicState.playback {
        case .playing:
            state.localMusicState.player.pause()
            core.fire(event: Updated(item: Playback.paused))
        case .paused:
            state.localMusicState.player.play()
            core.fire(event: Updated(item: Playback.playing))
        default:
            return
        }
    }
    
}

