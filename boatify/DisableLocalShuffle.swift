//
//  DisableLocalShuffle.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct DisableLocalShuffle: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        core.fire(event: Updated(item: Shuffle.off))
        core.fire(command: PlaySelectedLocalTrack())
    }
    
}

