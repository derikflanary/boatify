//
//  Recorderswift
//  boatify
//
//  Created by Derik Flanary on 11/28/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import AVFoundation

struct RecorderState: State {
    
    var progress: TrackProgress = TrackProgress(percent: 0.0)
    var audioRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?
    var volume = Volume(min: 0.5, max: 1.0)
    var sensitivity: Sensitivity = Sensitivity(constant: 0.5)
    var shouldStartRecording = false
    
    mutating func react(to event: Event) {
        
        switch event {
        case _ as RecordingRequested:
            shouldStartRecording = true
        case let event as RecordingSetup:
            audioRecorder = event.audioRecorder
        case _ as RecordingStarted:
            shouldStartRecording = false
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            audioRecorder?.updateMeters()
        case _ as RecordingStopped:
            audioRecorder?.stop()
        case let event as Updated<Volume>:
            volume = event.item
        case let event as UpdatedVolumeSettings:
            volume.min = event.newMin
            volume.max = event.newMax
        case let event as Updated<Sensitivity>:
            sensitivity = event.item
        default:
            break
        }
    }

}

struct TrackProgress {
    var percent: Float
}
