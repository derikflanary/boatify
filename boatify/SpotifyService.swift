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
    
    func selectSpotify() -> Action {
        return Selected(item: MusicState.spotify)
    }
    
    func loginToSpotify() {
        SPTAuth.defaultInstance().clientID = SpotifyService.kClientId
        SPTAuth.defaultInstance().redirectURL = URL(string: kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserLibraryReadScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = "SpotifySession"
        let loginURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        UIApplication.shared.openURL(loginURL!)
    }
    
    // TODO: - Get refresh working
    func refresh(_ session: SPTSession) -> AppActionCreator {
        return { state, store in
            SPTAuth.defaultInstance().clientID = SpotifyService.kClientId
            SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserLibraryReadScope]
            SPTAuth.defaultInstance().renewSession(session) { (error, newSession) in
                if let error = error {
                    print(error)
                } else {
                    store.dispatch(Retrieved(item: newSession))
                }
            }
            return nil
        }

    }
    
    func handleAuth(for url: URL) -> AppActionCreator {
        return { state, store in
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: { error, session in
                if let error = error {
                    print(error)
                } else {
                    store.dispatch(Retrieved(item: session))
                    store.dispatch(self.loginPlayer)
                }
            })
            return nil
        }
    }
    
    func loginPlayer(_ state: AppState, store: Store<AppState>) -> Action? {
        guard let session = state.spotifyState.session else { return nil }
        do {
            try player?.start(withClientId: SpotifyService.kClientId)
            player?.login(withAccessToken: session.accessToken)
            return Updated(item: ViewState.loading(message: "Loading your playlists..."))
        } catch {
            print(error)
            return nil
        }
    }
    
    func getPlaylists(_ state: AppState, store: Store<AppState>) -> Action? {
        SPTPlaylistList.playlists(forUser: state.spotifyState.session?.canonicalUsername, withAccessToken: state.spotifyState.session?.accessToken, callback: { (error, list) in
            
            guard let playlists = list as? SPTPlaylistList else { return }
            guard let partialPlaylists = playlists.tracksForPlayback() as? [SPTPartialPlaylist] else { return }
            let imageURIs = partialPlaylists.map { $0.largestImage.imageURL }
            var images = [UIImage]()
            for uri in imageURIs {
                if let uri = uri, let imageData = try? Data(contentsOf: uri), let image = UIImage(data: imageData) {
                    images.append(image)
                }
            }
            store.dispatch(Loaded(items: partialPlaylists))
            store.dispatch(Loaded(items: images))
        })
        return nil
    }
    
    func getPlaylistDetails(_ state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.spotifyState.selectedPlaylist else { return nil }
        SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: state.spotifyState.session?.accessToken) { error, snapshot in
            if let error = error {
                print(error)
            } else {
                guard let playlistSnapShot = snapshot as? SPTPlaylistSnapshot else { return }
                let trackList = playlistSnapShot.firstTrackPage
                if let tracks = trackList?.items as? [SPTPartialTrack] {
                    store.dispatch(Loaded(items: tracks))
                }
            }
        }
        return nil
    }

    func select(_ playlist: SPTPartialPlaylist) -> Action {
        return Selected(item: playlist)
    }
    
    func select(_ track: SPTPartialTrack) -> Action {
        return Selected(item: track)
    }
    
    func update(_ volume: Double) {
        player?.setVolume(volume, callback: nil)
        print(player?.volume as Any)
    }
    
    func updateIsPlaying() {
        guard let player = player else { return }
        player.setIsPlaying(!player.playbackState.isPlaying, callback: { error in
            if let error = error {
                print(error)
            }
        })
    }
    
    func trackProgress() -> Float {
        guard let player = player, let trackDuration = player.metadata.currentTrack?.duration else { return 0.0 }
        let percent = (player.playbackState.position) / (trackDuration)
        return Float(percent)
    }
    
    func play(uris: [URL]) {
        
    }
    
    func play(uri: URL)  {
        player?.playSpotifyURI(uri.absoluteString, startingWith: 0, startingWithPosition: 0, callback: { error in
            if let error = error {
                print(error)
            }
        })
    }
    
    func playSelectedPlaylist(at position: Int) -> AppActionCreator {
        return { state, store in
            guard let playlist = state.spotifyState.selectedPlaylist else { return nil }
            store.dispatch(Play(item: playlist))
            self.player?.playSpotifyURI(playlist.playableUri.absoluteString, startingWith: UInt(position), startingWithPosition: 0, callback: { error in
                if let error = error {
                    print(error)
                }
            })
            return nil
        }
    }
    
    func set(volume: Double) {
        player?.setVolume(volume, callback: nil)
    }
    
    func advanceToNextTrack() {
        player?.skipNext { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func advanceToPreviousTrack() {
        player?.skipPrevious { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    func shufflePlaylist(_ state: AppState, store: Store<AppState>) -> Action? {
        player?.setShuffle(true, callback: { error in
            if let error = error {
                print(error)
            } else {
                store.dispatch(Updated(item: Shuffle.on))
            }
        })
        return nil
    }
    
    func unshufflePlaylist(_ state: AppState, store: Store<AppState>) -> Action? {
        player?.setShuffle(false, callback: { error in
            if let error = error {
                print(error)
            } else {
                store.dispatch(Updated(item: Shuffle.off))
            }
        })
        return nil
    }
    
}


