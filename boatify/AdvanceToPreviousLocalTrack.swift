//
//  AdvanceToPreviousLocalTrack.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct AdvanceToPreviousLocalTrack: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let playlist = state.localMusicState.selectedPlaylist, let item = state.localMusicState.currentTrack, let index = playlist.items.index(of: item) else { return }
        if index > 0 {
            let nextItem = playlist.items[index - 1]
            core.fire(event: Selected(item: nextItem))
            core.fire(command: PlaySelectedLocalTrack())
        }
    }
    
}

