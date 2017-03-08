//
//  LocalMusicState.swift
//  boatify
//
//  Created by Derik Flanary on 8/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import MediaPlayer
import AVFoundation

struct LocalMusicState: State {
    
    var playlists = [MPMediaItemCollection]()
    var playlistsLoaded = false
    var selectedPlaylist: MPMediaPlaylist?
    var currentPlaylist: MPMediaPlaylist?
    var selectedTrack: MPMediaItem?
    var currentTrack: MPMediaItem?
    var player = AVQueuePlayer()
    var playback = Playback.stopped
    var trackPercent: Double = 0.0
    var shuffle = Shuffle.off
    
    
    mutating func react(to event: Event) {
        
        switch event {
        case let event as Loaded<MPMediaItemCollection>:
            playlists = event.items
            playlistsLoaded = true
        case let event as Selected<MPMediaPlaylist>:
            selectedPlaylist = event.item
        case let event as Selected<MPMediaItem>:
            selectedTrack = event.item
        case let event as Playing:
            currentTrack = event.item
            selectedTrack = event.item
            playback = .playing
        case let event as Updated<Playback>:
            playback = event.item
        case let event as UpdatedTrackProgress:
            trackPercent = event.percent
        case let event as Updated<Shuffle>:
            shuffle = event.item
        case let event as Play<MPMediaPlaylist>:
            currentPlaylist = event.item
        case let event as Updated<Volume>:
            player.volume = Float(event.item.current)
        case _ as Reset<MPMediaPlaylist>:
            selectedPlaylist = nil
        default:
            break
        }
    }
    
}
