//
//  PauseSpotify.swift
//  boatify
//
//  Created by Derik Flanary on 3/9/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct PauseSpotify: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let player = SPTAudioStreamingController.sharedInstance() else { return }
        player.setIsPlaying(false) { (error) in
            if let error = error {
                print(error)
            } else {
                core.fire(event: Updated(item: Playback.paused))
            }
        }
    }
    
}

