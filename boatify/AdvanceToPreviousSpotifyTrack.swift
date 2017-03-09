//
//  AdvanceToPreviousSpotifyTrack.swift
//  boatify
//
//  Created by Derik Flanary on 3/9/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct AdvanceToPreviousSpotifyTrack: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let player = SPTAudioStreamingController.sharedInstance() else { return }
        player.skipPrevious { error in
            if let error = error {
                print(error)
            } else {
                switch state.spotifyState.playback {
                case .paused, .stopped:
                    core.fire(command: PauseSpotify())
                case .playing:
                    break
                }
            }
        }
    }
    
}

