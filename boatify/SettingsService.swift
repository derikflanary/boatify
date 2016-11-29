//
//  SettingsService.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift


struct SettingsService {
    
    func updateVolumes(minVolume: Float, maxVolume: Float) -> Action {
        return Updated(item: Volume(min: Double(minVolume), max: Double(maxVolume)))
    }
    
    func resetMusicState() -> Action {
        return Updated(item: MusicState.none)
    }
    
}
