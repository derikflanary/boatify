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

struct AppState: StateType {
    
    // MARK: - Shared Store
    
    static var sharedStore = Store<AppState>(reducer: AppReducer(), state: AppState(), middleware: [loggingMiddleware])
    
    
    // MARK: - State components
    
    var spotifyState = SpotifyState()
    var localMusicState = LocalMusicState()
    
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5
    var audioRecorder: AVAudioRecorder?
    var viewState = ViewState.preLoggedIn
    var musicState = MusicState.none

}


typealias AppActionCreator = (_ state: AppState, _ store: Store<AppState>) -> Action?
