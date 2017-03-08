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
    var playback = Playback.stopped
    
    
    mutating func react(to event: Event) {
        
        switch event {
        case _ as AppLaunched:
            session = auth?.session
        case let event as Retrieved<SPTSession>:
            session = event.item
        case let event as Loaded<SPTPartialPlaylist>:
            playlists = event.items
        case let event as Loaded<UIImage>:
            playlistImages = event.items
        case let event as Selected<SPTPartialPlaylist>:
            selectedPlaylist = event.item
        case let event as Loaded<SPTPartialTrack>:
            tracks = event.items
        case let event as Selected<SPTPartialTrack>:
            selectedTrack = event.item
        case let event as Play<SPTPartialPlaylist>:
            currentPlaylist = event.item
            playback = .playing
        case let event as Updated<Playback>:
            playback = event.item
        case let event as Updated<Volume>:
            SPTAudioStreamingController.sharedInstance().setVolume(event.item.current, callback: nil)
        case let event as Updated<Shuffle>:
            shuffle = event.item
        case _ as Reset<SPTPartialPlaylist>:
            selectedPlaylist = nil
        default:
            break
        }
    }

}
