//
//  UpdateLocalTrackProgress.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import CoreMedia

struct UpdateLocalTrackProgress: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let item = state.localMusicState.currentTrack else { return }
        
        let currentTime = state.localMusicState.player.currentTime().seconds
        let totalTime = item.playbackDuration
        let percent = currentTime / Double(totalTime)
        core.fire(event: UpdatedTrackProgress(percent: percent))
    }
    
}

struct UpdateLocalTrackLocation: Command {
    
    var location: Double
    
    init(location: Double) {
        self.location = location
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let item = state.localMusicState.currentTrack else { return }
        let time = CMTime.init(seconds: location, preferredTimescale: 600)
        state.localMusicState.player.seek(to: time)
    }
    
}

