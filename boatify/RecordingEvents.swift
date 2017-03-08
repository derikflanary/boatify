//
//  RecordingEvents.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor
import AVFoundation
import AVKit

struct RecordingSetup: Event {
    let audioRecorder: AVAudioRecorder
}

struct RecordingStopped: Event { }

struct RecordingStarted: Event { }

struct TimerStarted: Event { }

