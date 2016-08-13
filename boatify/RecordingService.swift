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

struct RecordingService {
    
    func setupRecording(state: AppState, store: Store<AppState>) -> Action? {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            
            let fileManager = NSFileManager.defaultManager()
            let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let documentDirectory = urls[0] as NSURL
            let soundURL = documentDirectory.URLByAppendingPathComponent("sound.caf")
            
            let settings: [String : AnyObject] = [  AVSampleRateKey:44100.0,
                                                    AVNumberOfChannelsKey:1,AVEncoderBitRateKey:12800,
                                                    AVLinearPCMBitDepthKey:16,
                                                    AVEncoderAudioQualityKey:AVAudioQuality.Low.rawValue]
            
            let audioRecorder = try AVAudioRecorder(URL: soundURL, settings: settings)
            
            audioRecorder.meteringEnabled = true
            return RecordingSetup(audioRecorder: audioRecorder)
        } catch {
            print(error)
            return nil
        }

    }
}
