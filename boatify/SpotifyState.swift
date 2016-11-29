//
//  SpotifyState.swift
//  boatify
//
//  Created by Derik Flanary on 8/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift

struct SpotifyState {
    
    var session: SPTSession?
    var playlists = [SPTPartialPlaylist]()
    var playlistImages = [UIImage]()
    var selectedPlaylist: SPTPartialPlaylist?
    var currentPlaylist: SPTPartialPlaylist?
    var tracks = [SPTPartialTrack]()
    var selectedTrack: SPTPartialTrack?
    let auth = SPTAuth.defaultInstance()
    var shuffle = Shuffle.off
    var isPlaying: Bool {
        guard SPTAudioStreamingController.sharedInstance().playbackState != nil else { return false }
        return SPTAudioStreamingController.sharedInstance().playbackState.isPlaying
    }
    
    
    func reduce(_ action: Action) -> SpotifyState {
        var state = self
        
        switch action {
        case _ as AppLaunched:
            state.session = auth?.session
        case let action as Retrieved<SPTSession?>:
            state.session = action.item
        case let action as Loaded<SPTPartialPlaylist>:
            state.playlists = action.items
        case let action as Loaded<UIImage>:
            state.playlistImages = action.items
        case let action as Selected<SPTPartialPlaylist>:
            state.selectedPlaylist = action.item
        case let action as Loaded<SPTPartialTrack>:
            state.tracks = action.items
        case let action as Selected<SPTPartialTrack>:
            state.selectedTrack = action.item
        case let action as Play<SPTPartialPlaylist>:
            state.currentPlaylist = action.item
        case let action as Updated<Shuffle>:
            state.shuffle = action.item
        case _ as Reset<SPTPartialPlaylist>:
            state.selectedPlaylist = nil
        default:
            break
        }
        return state
    }
    
}
