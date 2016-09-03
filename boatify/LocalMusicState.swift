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
import AVFoundation

struct LocalMusicState {
    
    var playlists = [MPMediaItemCollection]()
    var playlistsLoaded = false
    var selectedPlaylist: MPMediaPlaylist?
    var selectedTrack: MPMediaItem?
    var currentTrack: MPMediaItem?
    var player = AVQueuePlayer()
    var playback = Playback.stopped
    var trackPercent: Double = 0.0
    var shuffle = false
    
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
        case let action as Playing:
            state.currentTrack = action.item
            state.selectedTrack = action.item
            state.playback = .playing
        case let action as Updated<Playback>:
            state.playback = action.item
        case let action as UpdatedTrackProgress:
            state.trackPercent = action.percent
        default:
            break
        }
        return state
    }
    
}
