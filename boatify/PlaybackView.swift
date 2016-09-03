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
    func pausePlayTapped()
    func previousTapped()
    func expandTapped()
}

class PlaybackView: UIView {
    
    var delegate: PlaybackViewDelegate?
    var paused: Bool = false {
        didSet {
            if paused {
                if let image = UIImage(named: "play") {
                    playPauseButton.setImage(image, forState: .Normal)
                }
            } else {
                if let image = UIImage(named: "pause") {
                    playPauseButton.setImage(image, forState: .Normal)
                }
            }
        }
    }

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction func nextButtonTapped() {
        delegate?.nextTapped()
    }
    
    @IBAction func playPauseTapped() {
        
        delegate?.pausePlayTapped()
    }
    
    @IBAction func previousButtonTapped() {
        delegate?.previousTapped()
    }
    
    @IBAction func expandTapped() {
        delegate?.expandTapped()
    }
    
}
