//
//  AdvanceToNextLocalTrack.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct AdvanceToNextLocalTrack: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let playlist = state.localMusicState.selectedPlaylist else { return }
        guard let item = state.localMusicState.currentTrack else { return }
        
        state.localMusicState.player.advanceToNextItem()
        guard let index = playlist.items.index(of: item) else { return }
        
        if index <= playlist.items.count - 1 {
            let nextItem = playlist.items[index + 1]
            core.fire(event: Playing(item: nextItem))
        } else {
            return
        }
    }
    
}
