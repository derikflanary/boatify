//
//  Volume.swift
//  boatify
//
//  Created by Derik Flanary on 11/28/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

struct Volume {
    var min: Double = 1.0
    var max: Double = 0.5
    var current: Double = 0.0
    
    var mid: Double {
        return (max + min) / 2
    }
    
    init(min: Double, max: Double) {
        self.min = min
        self.max = max
    }
    
}
