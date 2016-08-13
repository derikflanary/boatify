//
//  AppReducer.swift
//  boatify
//
//  Created by Derik Flanary on 8/6/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift
import UIKit


struct AppReducer: Reducer {
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        var state = state ?? AppState()
        
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
        case let action as VolumesUpdated:
            state.maxVolume = action.maxVolume
            state.minVolume = action.minVolume
        default:
            break
        }
        
        return state
    }
    
}


