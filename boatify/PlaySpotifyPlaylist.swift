//
//  PlaySpotifyPlaylist.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct PlaySpotifyPlaylist: Command {
    let playlist: SPTPartialPlaylist
    
    init(playlist: SPTPartialPlaylist) {
        self.playlist = playlist
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(playlist.playableUri.absoluteString, startingWith: 0, startingWithPosition: 0, callback: { error in
            if let error = error {
                print(error)
            } else {
                core.fire(event: Play(item: self.playlist))
            }
        })
    }
}

