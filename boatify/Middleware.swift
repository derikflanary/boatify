//
//  Middleware.swift
//  boatify
//
//  Created by Derik Flanary on 8/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor


struct LoggingMiddleware: Middleware {
    
    func process(event: Event, state: State) {
        print(event)
    }
}

