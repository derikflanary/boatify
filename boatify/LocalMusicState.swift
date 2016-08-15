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
    var selectedPlaylist: MPMediaPlaylist?
    var selectedTrack: MPMediaItem?
    
    func reduce(action: Action) -> LocalMusicState {
        var state = self
        
        switch action {
        case let action as Loaded<MPMediaItemCollection>:
            state.playlists = action.items
            state.playlistsLoaded = true
        case let action as Selected<MPMediaPlaylist>:
            state.selectedPlaylist = action.item
        case let action as Selected<MPMediaItem>:
            state.selectedTrack = action.item
        default:
            break
        }
        return state
    }
    
}
