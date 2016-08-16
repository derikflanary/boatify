//
//  MusicService.swift
//  boatify
//
//  Created by Derik Flanary on 8/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift
import MediaPlayer

enum Playback {
    case playing
    case paused
    case stopped
}

struct Playing: Action {
    let item: MPMediaItem
}

struct MusicService {
    
    func selectLocal() -> Action {
        return Selected(item: MusicState.local)
    }
    
    func getPlaylists() -> AppActionCreator {
        return { state, store in
            let query = MPMediaQuery.playlistsQuery()
            guard let collections = query.collections else { return nil }
            store.dispatch(Loaded(items: collections))
            return nil
        }
        
    }
    
    func select(playlist: MPMediaPlaylist) -> Action {
        return Selected(item: playlist)
    }
    
    func select(track: MPMediaItem) -> Action {
        return Selected(item: track)
    }
    
    func playPlaylist(state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.localMusicState.selectedPlaylist else { return nil }
        
        let player = state.localMusicState.player
        player.removeAllItems()
        
        for item in playlist.items {
            guard let url = item.assetURL else { continue }
            let playerItem = AVPlayerItem(URL: url)
            player.insertItem(playerItem, afterItem: nil)
        }
        player.volume = Float(state.minVolume)
        player.play()
        return Playing(item: playlist.items.first!)
    }
    
    func update(volume: Float) -> AppActionCreator {
        return { state, store in
            let player = state.localMusicState.player
            player.volume = volume
            print(player.volume)
            return nil
        }
    }
    
    func updatePlayPause(state: AppState, store: Store<AppState>) -> Action? {
        switch state.localMusicState.playback {
        case .playing:
            state.localMusicState.player.pause()
            return Updated(item: Playback.paused)
        case .paused:
            state.localMusicState.player.play()
            return Updated(item: Playback.playing)
        default:
            return nil
        }
    }
    
}