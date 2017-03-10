//
//  RecordingUpdated.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct UpdateRecording: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        guard let audioRecorder = state.recorderState.audioRecorder else { return }
        var volume = state.recorderState.volume
        audioRecorder.updateMeters()
        let averagePower = audioRecorder.averagePower(forChannel: 0)
        if averagePower < -22.5 {
            volume.current = volume.min
        } else if averagePower < -15.0 {
            volume.current = volume.mid
        } else {
            volume.current = volume.max
        }
        core.fire(event: Updated(item: volume))
        print(averagePower)
        print(volume.current)
    }
}

struct updateVolumeSettings: Command {
    
    let newMin: Double
    let newMax: Double
    
    init(newMin: Double, newMax: Double) {
        self.newMin = newMin
        self.newMax = newMax
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        
    }
}
