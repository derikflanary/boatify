//
//  LoginPlayer.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct LoginPlayer: Command {
    
    private var player = SPTAudioStreamingController.sharedInstance()
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let session = state.spotifyState.session else { return }
        do {
            try player?.start(withClientId: SpotifyService.kClientId)
            player?.login(withAccessToken: session.accessToken)
            core.fire(event: Updated(item: ViewState.loading(message: "Loading your playlists...")))
        } catch {
            print(error)
        }
    }
    
}
