//
//  SpotifyState.swift
//  boatify
//
//  Created by Derik Flanary on 8/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct SpotifyState: State {
    
    var session: SPTSession?
    var player = SPTAudioStreamingController.sharedInstance()
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
    
    mutating func react(to event: Event) {
        var state = self
        
        switch event {
        case _ as AppLaunched:
            state.session = auth?.session
        case let event as Retrieved<SPTSession?>:
            state.session = event.item
        case let event as Loaded<SPTPartialPlaylist>:
            state.playlists = event.items
        case let event as Loaded<UIImage>:
            state.playlistImages = event.items
        case let event as Selected<SPTPartialPlaylist>:
            state.selectedPlaylist = event.item
        case let event as Loaded<SPTPartialTrack>:
            state.tracks = event.items
        case let event as Selected<SPTPartialTrack>:
            state.selectedTrack = event.item
        case let event as Play<SPTPartialPlaylist>:
            state.currentPlaylist = event.item
        case let event as Updated<Volume>:
            SPTAudioStreamingController.sharedInstance().setVolume(event.item.current, callback: nil)
        case let event as Updated<Shuffle>:
            state.shuffle = event.item
        case _ as Reset<SPTPartialPlaylist>:
            state.selectedPlaylist = nil
        default:
            break
        }
    }

}
