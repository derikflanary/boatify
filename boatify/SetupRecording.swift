//
//  SetupRecording.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import AVFoundation
import AVKit

struct SetupRecording: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
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
            core.fire(event: RecordingSetup(audioRecorder: audioRecorder))
        } catch {
            print(error)
            
        }
    }
    
}
