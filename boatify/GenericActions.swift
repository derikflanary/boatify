//
//  GenericActions.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor


/// These items were loaded from an API query
struct Loaded<T>: Event {
    let items: [T]
}

/// This item was loaded from an API query
struct Retrieved<T>: Event {
    let item: T
}

/// This selects an item from a list
struct Selected<T>: Event {
    let item: T
}

/// This updates an existing item
struct Updated<T>: Event {
    let item: T
}

/// This plays a playlist or track
struct Play<T>: Event {
    let item: T
}

/// This resets an item
struct Reset<T>: Event { }

struct AppLaunched: Event { }
