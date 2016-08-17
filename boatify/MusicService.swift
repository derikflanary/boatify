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

struct UpdatedTrackProgress: Action {
    let percent: Double
}

struct StoppedPlayer: Action { }

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
        guard playlist.items.count > 0 else { return nil }
        
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
    
    func playTrack(state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.localMusicState.selectedPlaylist else { return nil }
        guard let selectedTrack = state.localMusicState.selectedTrack else { return nil }
        
        let player = state.localMusicState.player
        player.removeAllItems()
        var advanceToNext = true
        
        for item in playlist.items {
            guard let url = item.assetURL else { continue }
            let playerItem = AVPlayerItem(URL: url)
            player.insertItem(playerItem, afterItem: nil)
            if item != selectedTrack && advanceToNext {
                player.advanceToNextItem()
            } else if item == selectedTrack {
                advanceToNext = false
            }
        }
        
        player.volume = Float(state.minVolume)
        player.play()
        return Playing(item: selectedTrack)
        
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
    
    func advanceToNextTrack(state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.localMusicState.selectedPlaylist else { return nil }
        guard let item = state.localMusicState.currentTrack else { return nil }
        
        state.localMusicState.player.advanceToNextItem()
        guard let index = playlist.items.indexOf(item) else { return nil }
        
        if index <= playlist.items.count - 1 {
            let nextItem = playlist.items[index + 1]
            return Playing(item: nextItem)
        } else {
            return nil
        }
        
    }
    
    func advanceToPreviousTrack() -> AppActionCreator {
        return { state, store in
            guard let playlist = state.localMusicState.selectedPlaylist, item = state.localMusicState.currentTrack, index = playlist.items.indexOf(item) else { return nil }
            if index > 0 {
                let nextItem = playlist.items[index - 1]
                store.dispatch(Selected(item: nextItem))
                store.dispatch(self.playTrack)
            }
            return nil
        }
    }
    
    func updateTrackProgress(state: AppState, store: Store<AppState>) -> Action? {
        guard let item = state.localMusicState.currentTrack else { return nil }
        
        let currentTime = state.localMusicState.player.currentTime().seconds
        let totalTime = item.playbackDuration
        let percent = currentTime / Double(totalTime)
        return UpdatedTrackProgress(percent: percent)
    }
    
    func stopPlayer() -> Action {
        return StoppedPlayer()
    }
    
}

