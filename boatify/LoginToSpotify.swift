//
//  LoginToSpotify.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct LoginToSpotify: Command {
    
    private let kCallbackURL = "boatify-login://callback"
    private var spotifyAccess: SpotifyNetworkAccess = SpotifyNetworkAPIAccess()
    
    func execute(state: AppState, core: Core<AppState>) {
        SPTAuth.defaultInstance().clientID = SpotifyService.kClientId
        SPTAuth.defaultInstance().redirectURL = URL(string: kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserLibraryReadScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = "SpotifySession"
        guard let loginURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL() else { return }
        UIApplication.shared.open(loginURL, options: [:], completionHandler: nil)
        core.fire(event: Updated(item: ViewState.loading(message: "Loading your playlists...")))
    }
    
}

