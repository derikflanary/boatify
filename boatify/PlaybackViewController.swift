//
//  PlaybackViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/17/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor

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

    var core = App.sharedCore
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        core.remove(subscriber: self)
    }

    
    // MARK: - Interface actions
    
    @IBAction func nextButtonTapped() {
    }
    
    @IBAction func previousButtonTapped() {
    }
    
    @IBAction func playPauseTapped() {
        switch core.state.musicState {
        case .spotify:
            if case .playing = core.state.spotifyState.playback {
                core.fire(event: Updated(item: Playback.paused))
            } else {
                core.fire(event: Updated(item: Playback.playing))
            }
        case .local:
            if case .playing = core.state.localMusicState.playback {
                core.fire(event: Updated(item: Playback.paused))
            } else {
                core.fire(event: Updated(item: Playback.playing))
            }
        case .none:
            break
        }
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

extension PlaybackViewController: Subscriber {
    
    func update(with state: AppState) {
        switch state.musicState {
        case .local:
            trackLabel.text = state.localMusicState.selectedTrack?.title
            artistLabel.text = state.localMusicState.selectedTrack?.artist
            switch state.localMusicState.playback {
            case .playing:
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            case .paused:
                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            case .stopped:
                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
            
            switch state.localMusicState.shuffle {
            case .off:
                shuffleButton.tintColor = UIColor.lightGray
            case .on:
                shuffleButton.tintColor = UIColor.black
            }
        case .spotify:
            guard let streamingController = SPTAudioStreamingController.sharedInstance() else { return }
            if streamingController.metadata != nil {
                trackLabel.text = streamingController.metadata.currentTrack?.name
                artistLabel.text = streamingController.metadata.currentTrack?.artistName                
            }
            guard streamingController.playbackState != nil else { return }
            switch state.spotifyState.playback {
            case .playing:
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            case .paused:
                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            case .stopped:
                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }

            if streamingController.playbackState.isShuffling {
                shuffleButton.tintColor = UIColor.black
            } else {
                shuffleButton.tintColor = UIColor.lightGray
            }
            
        case .none:
            break
            
        }
    }
}
