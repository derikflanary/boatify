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
            let query = MPMediaQuery.playlists()
            guard let collections = query.collections else { return nil }
            store.dispatch(Loaded(items: collections))
            return nil
        }
        
    }
    
    func select(_ playlist: MPMediaPlaylist) -> Action {
        return Selected(item: playlist)
    }
    
    func select(_ track: MPMediaItem) -> Action {
        return Selected(item: track)
    }
    
    func playPlaylist(_ state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.localMusicState.selectedPlaylist else { return nil }
        guard playlist.items.count > 0 else { return nil }
        
        let player = state.localMusicState.player
        player.removeAllItems()
        
        var tracks = playlist.items
        if case .on = state.localMusicState.shuffle {
            tracks.shuffled()
        }
        
        for item in tracks {
            guard let url = item.assetURL else { continue }
            let playerItem = AVPlayerItem(url: url)
            player.insert(playerItem, after: nil)
        }
        
        player.volume = Float(state.minVolume)
        player.play()
        return Playing(item: playlist.items.first!)
    }
    
    func playTrack(_ state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.localMusicState.selectedPlaylist else { return nil }
        guard let selectedTrack = state.localMusicState.selectedTrack else { return nil }
        
        let player = state.localMusicState.player
        player.removeAllItems()
        
        var advanceToNext = true
        var tracks = playlist.items
        if case .on = state.localMusicState.shuffle {
            tracks.shuffled()
        }
        
        for item in tracks {
            guard let url = item.assetURL else { continue }
            let playerItem = AVPlayerItem(url: url)
            player.insert(playerItem, after: nil)
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
    
    func enableShuffle() -> AppActionCreator {
        return { state, store in
            store.dispatch(Updated(item: Shuffle.on))
            
            guard let playlist = state.localMusicState.selectedPlaylist else { return nil }
            guard let currentTrack = state.localMusicState.currentTrack else { return nil }
            let player = state.localMusicState.player
            
            var tracks = playlist.items
            tracks.shuffled()
            for track in tracks {
                if currentTrack != track {
                    guard let url = track.assetURL, let currentUrl = currentTrack.assetURL else { continue }
                    let playerItem = AVPlayerItem(url: url)
                    player.remove(playerItem)
                    let currentITem = AVPlayerItem(url: currentUrl)
                    player.insert(playerItem, after: currentITem)
                }
            }
            return nil
        }
        
    }
    
    func disableShuffle() -> AppActionCreator {
        return { state, store in
            store.dispatch(Updated(item: Shuffle.off))
            store.dispatch(self.playTrack)
            return nil
        }
    }
    
    func update(_ volume: Float) -> AppActionCreator {
        return { state, store in
            let player = state.localMusicState.player
            player.volume = volume
            print(player.volume)
            return nil
        }
    }
    
    func updatePlayPause(_ state: AppState, store: Store<AppState>) -> Action? {
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
    
    func advanceToNextTrack(_ state: AppState, store: Store<AppState>) -> Action? {
        guard let playlist = state.localMusicState.selectedPlaylist else { return nil }
        guard let item = state.localMusicState.currentTrack else { return nil }
        
        state.localMusicState.player.advanceToNextItem()
        guard let index = playlist.items.index(of: item) else { return nil }
        
        if index <= playlist.items.count - 1 {
            let nextItem = playlist.items[index + 1]
            return Playing(item: nextItem)
        } else {
            return nil
        }
        
    }
    
    func advanceToPreviousTrack() -> AppActionCreator {
        return { state, store in
            guard let playlist = state.localMusicState.selectedPlaylist, let item = state.localMusicState.currentTrack, let index = playlist.items.index(of: item) else { return nil }
            if index > 0 {
                let nextItem = playlist.items[index - 1]
                store.dispatch(Selected(item: nextItem))
                store.dispatch(self.playTrack)
            }
            return nil
        }
    }
    
    func updateTrackProgress(_ state: AppState, store: Store<AppState>) -> Action? {
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

