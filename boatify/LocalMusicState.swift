//
//  LocalMusicState.swift
//  boatify
//
//  Created by Derik Flanary on 8/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift
import MediaPlayer

struct LocalMusicState {
    
    var playlists = [MPMediaItemCollection]()
    var playlistsLoaded = false
    
    func reduce(action: Action) -> LocalMusicState {
        var state = self
        
        switch action {
        case let action as Loaded<MPMediaItemCollection>:
            state.playlists = action.items
            state.playlistsLoaded = true
        default:
            break
        }
        return state
    }
    
}
