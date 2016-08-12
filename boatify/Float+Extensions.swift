//
//  Float+Extensions.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

extension Float {
    var percentForm: String {
        let percent = self * 100
        return String(format: "%.0f", percent)
    }
}
