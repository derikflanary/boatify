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
    let session: SPTSession
    
    init(session: SPTSession) {
        self.session = session
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        do {
            try player?.start(withClientId: SpotifyService.kClientId)
            player?.login(withAccessToken: session.accessToken)
        } catch {
            print(error)
            core.fire(event: Updated(item: ViewState.error(message: "Failed to login to Spotify. 😟")))
        }
    }
    
}
