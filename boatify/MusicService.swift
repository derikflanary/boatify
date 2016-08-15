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
    
    func play(playlist: MPMediaItemCollection) {
        let appMusicPlayer = MPMusicPlayerController.systemMusicPlayer()
        appMusicPlayer.setQueueWithItemCollection(playlist)
        appMusicPlayer
        appMusicPlayer.play()
    }
    
    func select(track: MPMediaItem) -> Action {
        return Selected(item: track)
    }
    
}