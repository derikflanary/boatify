//
//  MusicService.swift
//  boatify
//
//  Created by Derik Flanary on 8/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import MediaPlayer

enum Playback {
    case playing
    case paused
    case stopped
}

struct Playing: Event {
    let item: MPMediaItem
}

struct UpdatedTrackProgress: Event {
    let percent: Double
}

struct StoppedPlayer: Event { }

struct TrackingProgress: Event { }

