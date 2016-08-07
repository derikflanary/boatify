//
//  SpotifyService.swift
//  boatify
//
//  Created by Derik Flanary on 8/6/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift

struct SessionLoaded: Action {
    let session: SPTSession
}

struct AppLaunched: Action { }

struct SpotifyService {
    
    // MARK: - Properties
    
    static let kClientId = "08e656aa8c444173ab066eb4a3ca7bf7"
    let kCallbackURL = "boatify-login://callback"
    var spotifyAccess: SpotifyNetworkAccess = SpotifyNetworkAPIAccess()

    
    // MARK: - Main function
    
    func checkForSession() -> Action {
        return AppLaunched()
    }
    
    func loginToSpotify() {
        SPTAuth.defaultInstance().clientID = SpotifyService.kClientId
        SPTAuth.defaultInstance().redirectURL = NSURL(string: kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserLibraryReadScope]
        let loginURL = SPTAuth.defaultInstance().loginURL
        UIApplication.sharedApplication().openURL(loginURL)
    }
    
    func refresh(session: SPTSession) -> AppActionCreator {
        return { state, store in
            SPTAuth.defaultInstance().clientID = SpotifyService.kClientId
            SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserLibraryReadScope]
            SPTAuth.defaultInstance().renewSession(session) { (error, newSession) in
                if error == nil {
                    store.dispatch(SessionLoaded(session: newSession))
                } else {
                    print(error)
                }
            }
            return nil
        }

    }
    
    func handleAuth(for url: NSURL) -> Store<AppState>.ActionCreator {
        return { state, store in
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { error, session in
                if error != nil {
                    print(error)
                } else {
                    store.dispatch(SessionLoaded(session: session))
                }
            })
            return nil
        }
    }
    
    func getPlaylistsWithSession(session: SPTSession) -> Store<AppState>.ActionCreator {
        return { state, store in
            SPTPlaylistList.playlistsForUserWithSession(session, callback: { error, playlistList in
                guard let playlists = playlistList as? SPTPlaylistList else { return }
                
            })
            return nil
        }
    }
    
}


