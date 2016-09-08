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
        case let action as RecordingSetup:
            state.audioRecorder = action.audioRecorder
        case let action as Selected<MusicState>:
            state.musicState = action.item
        case let action as VolumesUpdated:
            state.maxVolume = action.maxVolume
            state.minVolume = action.minVolume
        case let action as Updated<ViewState>:
            state.viewState = action.item
        case _ as Loaded<SPTPartialPlaylist>:
            state.viewState = .viewing
        case let action as Updated<MusicState>:
            state.musicState = action.item
            if action.item == .none {
                state.localMusicState = LocalMusicState()
                let session = state.spotifyState.session
                state.spotifyState.selectedPlaylist = nil
                state.spotifyState.session = session
            }
        default:
            break
        }
        
        state.spotifyState = state.spotifyState.reduce(action)
        state.localMusicState = state.localMusicState.reduce(action)
        
        return state
    }
    
}


