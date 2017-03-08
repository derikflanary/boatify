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
    var progressTimer: Timer?
    var volume = Volume(min: 0.5, max: 1.0)
    
    mutating func react(to event: Event) {
        
        switch event {
        case let event as RecordingSetup:
            audioRecorder = event.audioRecorder
        case let event as Updated<TrackProgress>:
            progress = event.item
        case _ as RecordingStarted:
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            audioRecorder?.updateMeters()
            TimerController.sharedInstance.startMeter()
        case _ as RecordingStopped:
            TimerController.sharedInstance.stopMeter()
            audioRecorder?.stop()
        case let event as Updated<Volume>:
            volume = event.item
        default:
            break
        }
    }

}

struct TrackProgress {
    var percent: Float
}
