//
//  RequestPermissionToRecord.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import AVFoundation

struct RequestPermissionToRecord: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        if AVAudioSession.sharedInstance().recordPermission() == .granted {
            core.fire(command: SetupRecording())
            print("already granted")
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission({ allowed in
                if allowed {
                    core.fire(command: SetupRecording())
                    print("allowed")
                } else {
                    print("failed to record")
                }
            })
        }
    }
    
}

