//
//  GetSpotifyPlaylistDetails.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct GetSpotifyPlaylistDetails: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let playlist = state.spotifyState.selectedPlaylist else { return }
        SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: state.spotifyState.session?.accessToken) { error, snapshot in
            if let error = error {
                print(error)
            } else {
                guard let playlistSnapShot = snapshot as? SPTPlaylistSnapshot else { return }
                let trackList = playlistSnapShot.firstTrackPage
                if let tracks = trackList?.items as? [SPTPartialTrack] {
                    core.fire(event: Loaded(items: tracks))
                }
            }
        }
    }
}

