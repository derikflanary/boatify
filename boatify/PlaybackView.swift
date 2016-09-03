//
//  PlaybackView.swift
//  boatify
//
//  Created by Derik Flanary on 9/3/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit

protocol PlaybackViewDelegate {
    func nextTapped()
    func playPauseTapped()
    func previousTapped()
    func expandTapped()
}

class PlaybackView: UIView {
    
    var delegate: PlaybackViewDelegate?

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction func nextButtonTapped() {
        delegate?.nextTapped()
    }
    
    @IBAction func playPauseTapped() {
        delegate?.playPauseTapped()
    }
    
    @IBAction func previousButtonTapped() {
        delegate?.previousTapped()
    }
    
    @IBAction func expandTapped() {
        delegate?.expandTapped()
    }
    
}
