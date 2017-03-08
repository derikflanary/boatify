//
//  RefreshSpotifySession.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct RefreshSpotifySession: Command {
    
    let session: SPTSession
    
    init(session: SPTSession) {
        self.session = session
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        SPTAuth.defaultInstance().clientID = SpotifyService.kClientId
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserLibraryReadScope]
        SPTAuth.defaultInstance().renewSession(session) { (error, newSession) in
            if let error = error {
                print(error)
            } else {
                core.fire(event: Retrieved(item: newSession))
            }
        }        
    }
    
}

