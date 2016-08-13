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


struct AppState: StateType {
    
    // MARK: - Shared Store
    
    static var sharedStore = Store<AppState>(reducer: AppReducer(), state: AppState(), middleware: [])
    
    
    // MARK: - State components
    
    var session: SPTSession?
    var user: SPTUser?
    var playlists = [SPTPartialPlaylist]()
    var playlistImages = [UIImage]()
    var selectedPlaylist: SPTPartialPlaylist?
    var tracks = [SPTPartialTrack]()
    var selectedTrack: SPTPartialTrack?
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5

}


typealias AppActionCreator = (state: AppState, store: Store<AppState>) -> Action?
