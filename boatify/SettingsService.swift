//
//  SettingsService.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift

struct VolumesUpdated: Action {
    let minVolume: Double
    let maxVolume: Double
}

struct MinVolumeUpdated: Action {
    let volume: Double
}

struct SettingsService {
    
    func updateVolumes(minVolume minVolume: Float, maxVolume: Float) -> Action {
        return VolumesUpdated(minVolume: Double(minVolume), maxVolume: Double(maxVolume))
    }
    
    func resetMusicState() -> Action {
        
        return Updated(item: MusicState.none)
    }
    
}
