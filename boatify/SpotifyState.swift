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
    var user: SPTUser?
    var playlists = [SPTPartialPlaylist]()
    var playlistImages = [UIImage]()
    var selectedPlaylist: SPTPartialPlaylist?
    var tracks = [SPTPartialTrack]()
    var selectedTrack: SPTPartialTrack?
    
    
    func reduce(action: Action) -> SpotifyState {
        var state = self
        
        switch action {
        case _ as AppLaunched:
            guard let sessionData = NSUserDefaults.standardUserDefaults().objectForKey("SpotifySession") as? NSData, session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession else { break }
            state.session = session
        case let action as Retrieved<SPTSession!>:
            state.session = action.item
            let sessionData = NSKeyedArchiver.archivedDataWithRootObject(action.item)
            NSUserDefaults.standardUserDefaults().setObject(sessionData, forKey:"SpotifySession")
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
        default:
            break
        }
        return state
    }
    
}
