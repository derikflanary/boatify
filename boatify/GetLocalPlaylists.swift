//
//  GetLocalPlaylists.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import MediaPlayer

struct GetLocalPlaylists: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        let query = MPMediaQuery.playlists()
        guard let collections = query.collections else { return }
        core.fire(event: Loaded(items: collections))
    }
    
}
