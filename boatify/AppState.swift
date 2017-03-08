//
//  AppState.swift
//  boatify
//
//  Created by Derik Flanary on 8/6/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

//
//  AppState.swift
//  greatwork
//
//  Created by Tim on 4/7/16.
//  Copyright © 2016 OC Tanner Company, Inc. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import AVFoundation
import Reactor

enum App {
    static let sharedCore = Core(state: AppState(), middlewares: [
        LoggingMiddleware()
        ])
}

enum ViewState {
    case preLoggedIn
    case viewing
    case loading(message: String)
    case error(message: String)
}

enum MusicState {
    case spotify
    case local
    case none
}


struct AppState: State {
 
    // MARK: - State components
    
    var recorderState = RecorderState()
    var spotifyState = SpotifyState()
    var localMusicState = LocalMusicState()
    
    var viewState = ViewState.preLoggedIn
    var musicState = MusicState.none

    
    mutating func react(to event: Event) {
        
        switch event {
        case let event as Selected<MusicState>:
            musicState = event.item
        case let event as Updated<ViewState>:
            viewState = event.item
        case _ as Loaded<SPTPartialPlaylist>:
            viewState = .viewing
        case let event as Updated<MusicState>:
            musicState = event.item
            if event.item == .none {
                localMusicState = LocalMusicState()
                let session = spotifyState.session
                spotifyState.selectedPlaylist = nil
                spotifyState.session = session
            }
        default:
            break
        }
        
        recorderState.react(to: event)
        spotifyState.react(to: event)
        localMusicState.react(to: event)
    }
    
}

