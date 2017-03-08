//
//  ShuffleSpotifyPlaylist.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct ShuffleSpotifyPlaylist: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        SPTAudioStreamingController.sharedInstance().setShuffle(true, callback: { error in
            if let error = error {
                print(error)
            } else {
                core.fire(event: Updated(item: Shuffle.on))
            }
        })
        
    }
}

