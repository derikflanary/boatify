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
    func shuffleTapped(_ shuffle: Shuffle)
}

class PlaybackView: UIView {
    
    var delegate: PlaybackViewDelegate?
    var paused: Bool = false {
        didSet {
            if paused {
                guard let image = UIImage(named: "play") else { return }
                playPauseButton.setImage(image, for: UIControlState())
            } else {
                guard let image = UIImage(named: "pause") else { return }
                playPauseButton.setImage(image, for: UIControlState())
            }
        }
    }
    
    var shuffle: Shuffle = .off {
        didSet {
            switch shuffle {
            case .on:
                guard let image = UIImage(named: "shuffleOn") else { break }
                shuffleButton.setImage(image, for: UIControlState())
            case .off:
                guard let image = UIImage(named: "shuffleOff") else { break }
                shuffleButton.setImage(image, for: UIControlState())
            }
        }
    }

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    
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
    
    @IBAction func shuffleTapped() {
        delegate?.shuffleTapped(shuffle)
    }
    
}
