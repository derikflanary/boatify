//
//  PlaySelectedPlaylist.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct PlaySelectedSpotifyPlaylist: Command {
    let startingTrackPosition: Int
    
    init(startingTrackPosition: Int) {
        self.startingTrackPosition = startingTrackPosition
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let playlist = state.spotifyState.selectedPlaylist else { return }
        core.fire(event: Play(item: playlist))
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(playlist.playableUri.absoluteString, startingWith: UInt(startingTrackPosition), startingWithPosition: 0, callback: { error in
            if let error = error {
                print(error)
            }
        })
    }
}


