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
import Reactor


class TimerController {
    
    static let sharedInstance = TimerController()
    
    var timer: Timer?
    var core = App.sharedCore
    
    func startMeter() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    func stopMeter() {
        timer?.invalidate()
    }
    
    @objc func updateMeter() {
        core.fire(command: UpdateRecording())
    }

}
