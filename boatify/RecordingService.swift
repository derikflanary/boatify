//
//  RecordingService.swift
//  boatify
//
//  Created by Derik Flanary on 8/13/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import ReSwift

struct RecordingSetup: Action {
    let audioRecorder: AVAudioRecorder
}

struct RecordingUpdated: Action { }

struct RecordingStopped: Action { }

struct RecordingStarted: Action { }

struct TimerStarted: Action { }

struct RecordingService {
    
    var progressTimer: Timer?
    
    func setupRecording(_ state: AppState, store: Store<AppState>) -> Action? {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = urls[0] as URL
            let soundURL = documentDirectory.appendingPathComponent("sound.caf")
            
            let settings: [String : AnyObject] = [  AVSampleRateKey:44100.0 as AnyObject,
                                                    AVNumberOfChannelsKey:1 as AnyObject,AVEncoderBitRateKey:12800 as AnyObject,
                                                    AVLinearPCMBitDepthKey:16 as AnyObject,
                                                    AVEncoderAudioQualityKey:AVAudioQuality.low.rawValue as AnyObject]
            
            let audioRecorder = try AVAudioRecorder(url: soundURL, settings: settings)
            
            audioRecorder.isMeteringEnabled = true
            return RecordingSetup(audioRecorder: audioRecorder)
        } catch {
            print(error)
            return nil
        }

    }
    
    func requestPermissionToRecord(_ state: AppState, store: Store<AppState>) -> Action? {
        if AVAudioSession.sharedInstance().recordPermission() == .granted {
            store.dispatch(setupRecording)
            print("already granted")
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission({ allowed in
                if allowed {
                    store.dispatch(self.setupRecording)
                    print("allowed")
                } else {
                    print("failed to record")
                }
            })
        }
        return nil
    }
    
    func startRecording() -> Action {
        return RecordingStarted()
    }
    
    func stopRecording() -> Action {
        return RecordingStopped()
    }
    
}

class TimerController {
    
    static let sharedInstance = TimerController()
    
    var timer: Timer?
    var store = AppState.sharedStore
    
    func startMeter() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    func stopMeter() {
        timer?.invalidate()
    }
    
    @objc func updateMeter() {
        store.dispatch(RecordingUpdated())
    }

}
