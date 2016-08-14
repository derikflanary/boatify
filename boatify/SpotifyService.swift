//
//  SpotifyService.swift
//  boatify
//
//  Created by Derik Flanary on 8/6/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift
import UIKit


struct AppLaunched: Action { }

struct SpotifyService {
    
    // MARK: - Properties
    
    static let kClientId = "08e656aa8c444173ab066eb4a3ca7bf7"
    let kCallbackURL = "boatify-login://callback"
    var spotifyAccess: SpotifyNetworkAccess = SpotifyNetworkAPIAccess()
    var player = SPTAudioStreamingController.sharedInstance()
    
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
    
    // TODO: - Get refresh working
    func refresh(session: SPTSession) -> AppActionCreator {
        return { state, store in
            SPTAuth.defaultInstance().clientID = SpotifyService.kClientId
            SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserLibraryReadScope]
            SPTAuth.defaultInstance().renewSession(session) { (error, newSession) in
                if error == nil {
                    store.dispatch(Retrieved(item: newSession))
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
                    store.dispatch(Retrieved(item: session))
                }
            })
            return nil
        }
    }
    
    func loginPlayer(state: AppState, store: Store<AppState>) -> Action? {
        guard let session = state.session else { return nil }
        do {
            try player.startWithClientId(SpotifyService.kClientId)
            player.loginWithAccessToken(session.accessToken)
            return Updated(item: ViewState.loading(message: "Loading your playlists..."))
        } catch {
            print(error)
            return nil
        }
    }
    
    func getUserObject(state: AppState, store: Store<AppState>) -> Action? {
        guard let session = state.session else { return nil }
        
        SPTUser.requestCurrentUserWithAccessToken(session.accessToken, callback: { (error, user) in
            if error != nil {
                print(error)
            } else {
                if let user = user as? SPTUser {
                    store.dispatch(Retrieved(item: user))
                }
            }
        })
        return nil
    }
    
    func getPlaylists() -> Store<AppState>.ActionCreator {
        return { state, store in
            guard let session = state.session else { return nil }

            SPTPlaylistList.playlistsForUserWithSession(session, callback: { error, list in
                guard let playlists = list as? SPTPlaylistList else { return }
                guard let partialPlaylists = playlists.tracksForPlayback() as? [SPTPartialPlaylist] else { return }
                let imageURIs = partialPlaylists.map { $0.largestImage.imageURL }
                var images = [UIImage]()
                for uri in imageURIs {
                    if let imageData = NSData(contentsOfURL: uri), image = UIImage(data: imageData) {
                        images.append(image)
                    }
                }
                store.dispatch(Loaded(items: partialPlaylists))
                store.dispatch(Loaded(items: images))
            })
            return nil
        }
    }
    
    func getPlaylistDetails(state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.selectedPlaylist, session = state.session else { return nil }
        
        SPTPlaylistSnapshot.playlistWithURI(playlist.uri, session: session) { error, snapshot in
            if error != nil {
                print(error)
            } else {
                guard let playlistSnapShot = snapshot as? SPTPlaylistSnapshot else { return }
                let trackList = playlistSnapShot.firstTrackPage
                if let tracks = trackList.items as? [SPTPartialTrack] {
                    store.dispatch(Loaded(items: tracks))
                }
            }
        }
        
        return nil
    }
    
    func select(playlist: SPTPartialPlaylist) -> Action {
        return Selected(item: playlist)
    }
    
    func select(track: SPTPartialTrack) -> Action {
        return Selected(item: track)
    }
    
    func update(volume: Double) {
        player.setVolume(volume, callback: nil)
        print(player.volume)
    }
    
    func updateIsPlaying() {
        player.setIsPlaying(!player.isPlaying) { error in
            if error != nil {
                print(error)
            }
        }
    }
    
    func trackProgress() -> Float {
        let percent = player.currentPlaybackPosition / player.currentTrackDuration
        return Float(percent)
    }
    
    func play(uris uris: [NSURL]) {
        
    }
    
    func play(uri uri: NSURL) {
        player.playURIs([uri], withOptions: SPTPlayOptions(), callback: nil)
    }
    
    
    
}


