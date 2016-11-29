//
//  RecorderState.swift
//  boatify
//
//  Created by Derik Flanary on 11/28/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift
import AVFoundation

struct RecorderState {
    
    var progress: TrackProgress = TrackProgress(percent: 0.0)
    var audioRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?
//    var timerController = TimerController.sharedInstance
    var progressTimer: Timer?
    var volume = Volume(min: 0.5, max: 1.0)
    
    func reduce(_ action: Action) -> RecorderState {
        var state = self
        
        switch action {
        case let action as RecordingSetup:
            state.audioRecorder = action.audioRecorder
        case let action as Updated<TrackProgress>:
            state.progress = action.item
        case _ as RecordingStarted:
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            audioRecorder?.updateMeters()
            TimerController.sharedInstance.startMeter()
        case _ as RecordingStopped:
            TimerController.sharedInstance.stopMeter()
            audioRecorder?.stop()
        case let action as Updated<Volume>:
            state.volume = action.item
        case _ as RecordingUpdated:
            guard let audioRecorder = state.audioRecorder else { break }
            audioRecorder.updateMeters()
            let averagePower = audioRecorder.averagePower(forChannel: 0)
            if averagePower < -22.5 {
                state.volume.current = state.volume.min
            } else if averagePower < -15.0 {
                state.volume.current = state.volume.mid
            } else {
                state.volume.current = state.volume.max
            }
            print(averagePower)
            print(state.volume.current)
        default:
            break
        }
        return state
    }

}

struct TrackProgress {
    var percent: Float
}
