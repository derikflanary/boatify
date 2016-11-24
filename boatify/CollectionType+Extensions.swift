//
//  CollectionType+Extensions.swift
//  boatify
//
//  Created by Derik Flanary on 8/17/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffled()
        return list
    }
}

extension MutableCollection where Index == Int {
    
    /// Shuffle the elements of `self` in-place.
    mutating func shuffled() {
        // empty and single-element collections don't shuffle
        let total = count.toIntMax()
        if total < 2 { return }
        
        for i in 0..<total - 1 {
            let j = Int(arc4random_uniform(UInt32(total - i))) + i
            guard i != j else { continue }
            swap(&self[Int(i)], &self[Int(j)])
        }
    }
    
}
