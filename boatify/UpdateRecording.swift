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
        let sensitivity = state.recorderState.sensitivity.constant
        var volume = state.recorderState.volume
        let powerConstant = -30.0 * sensitivity
        audioRecorder.updateMeters()
        let averagePower = audioRecorder.averagePower(forChannel: 0)
        if averagePower < powerConstant - 12.5 {
            volume.current = volume.min
        } else if averagePower < powerConstant {
            volume.current = volume.mid
        } else {
            volume.current = volume.max
        }
        core.fire(event: Updated(item: volume))
        print(averagePower)
        print(volume.current)
        print(powerConstant)
    }
}



