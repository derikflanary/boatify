//
//  GenericActions.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ReSwift


/// These items were loaded from an API query
struct Loaded<T>: Action {
    let items: [T]
}

/// This item was loaded from an API query
struct Retrieved<T>: Action {
    let item: T
}

/// This selects an item from a list
struct Selected<T>: Action {
    let item: T
}

/// This updates an existing item
struct Updated<T>: Action {
    let item: T
}