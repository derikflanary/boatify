//
//  PlaybackViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/17/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import ReSwift

class PlaybackViewController: UIViewController {
    
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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    
    @IBAction func nextButtonTapped() {
    }
    @IBAction func previousButtonTapped() {
    }
    @IBAction func playPauseTapped() {
    }
    @IBAction func shuffleTapped() {
    }
    @IBAction func expandButtonTapped() {
    }
    
//    extension ViewController: PlaybackViewDelegate {
//        
//        func pausePlayTapped() {
//            switch musicState {
//            case .spotify:
//                if player?.metadata != nil {
//                    break
//                } else {
//                    return
//                }
//            case .local:
//                switch playback {
//                case .playing, .paused:
//                    break
//                case .stopped:
//                    return
//                }
//            case .none:
//                return
//            }
//            playPauseTapped()
//        }
//        
//        func previousTapped() {
//            previousTrackTapped()
//        }
//        
//        func nextTapped() {
//            nextTrackTapped()
//        }
//        
//        func expandTapped() {
//            performSegue(withIdentifier: "PresentPlayback", sender: self)
//        }
//        
//        func shuffleTapped(_ shuffle: Shuffle) {
//            switch musicState {
//            case .spotify:
//                switch shuffle {
//                case .on:
//                    store.dispatch(spotifyService.unshufflePlaylist)
//                case .off:
//                    store.dispatch(spotifyService.shufflePlaylist)
//                }
//            case .local:
//                switch shuffle {
//                case .on:
//                    store.dispatch(musicService.disableShuffle())
//                case .off:
//                    store.dispatch(musicService.enableShuffle())
//                }
//                
//            case .none:
//                return
//            }
//        }
//        
//    }

}
