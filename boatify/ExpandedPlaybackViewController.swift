//
//  ExpandedPlaybackViewController.swift
//  boatify
//
//  Created by Derik Flanary on 5/25/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor
import Reactor
import MediaPlayer
import Hero

class ExpandedPlaybackViewController: UIViewController {
    
    var core = App.sharedCore
    
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var trackSlider: UISlider!
    
    var track = ""
    var artist = ""
    var progress: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        core.add(subscriber: self)
        trackSlider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)
        trackSlider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .highlighted)
        trackSlider.value = progress
        artistLabel.text = artist
        trackLabel.text = track
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        core.remove(subscriber: self)
    }

    @IBAction func expandButtonTapped() { }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            switch core.state.musicState {
            case .local:
                if Double(slider.value) != core.state.localMusicState.player.currentTime().seconds {
                    core.fire(command: UpdateLocalTrackLocation(location: Double(slider.value)))
                }
            case .spotify:
                break
            case .none:
                break
            }
        }
    }
   
}

extension ExpandedPlaybackViewController: Subscriber {
    
    func update(with state: AppState) {
        switch state.musicState {
        case .local:
        trackLabel.text = state.localMusicState.selectedTrack?.title
        artistLabel.text = state.localMusicState.selectedTrack?.artist
        if let selectedTrack = state.localMusicState.selectedTrack, let title = selectedTrack.title, let artist = selectedTrack.artist {
            
            let songInfo = [ MPMediaItemPropertyTitle: title,
                             MPMediaItemPropertyArtist: artist ]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
            
        }
//        switch state.localMusicState.playback {
//        case .playing:
//            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
//        case .paused:
//            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
//        case .stopped:
//            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
//        }
        
        switch state.localMusicState.shuffle {
        case .off:
            shuffleButton.tintColor = UIColor.lightGray
        case .on:
            shuffleButton.tintColor = UIColor.black
        }
        if let currentTrack = state.localMusicState.currentTrack {
            trackSlider.maximumValue = Float(currentTrack.playbackDuration)
            trackSlider.setValue(Float(state.localMusicState.player.currentTime().seconds), animated: true)
        }
//        if state.localMusicState.shouldStartTrackingProgress {
//            startTrackingProgress()
//        }
        case .spotify:
            guard let streamingController = SPTAudioStreamingController.sharedInstance() else { return }
            if streamingController.metadata != nil {
                guard let currentTrack = streamingController.metadata.currentTrack else { return }
                
                trackLabel.text = currentTrack.name
                artistLabel.text = currentTrack.artistName
                let songInfo: [String: String] = [
                    MPMediaItemPropertyTitle: currentTrack.name,
                    MPMediaItemPropertyArtist: currentTrack.artistName,
                    ]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
            }
            guard streamingController.playbackState != nil else { return }
//            switch state.spotifyState.playback {
//            case .playing:
//                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
//            case .paused:
//                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
//            case .stopped:
//                playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
//            }
            
            if streamingController.playbackState.isShuffling {
                shuffleButton.setImage(#imageLiteral(resourceName: "shuffleOn"), for: .normal)
            } else {
                shuffleButton.setImage(#imageLiteral(resourceName: "shuffleOff"), for: .normal)
            }
        
        case .none:
            break
            trackSlider.setValue(0, animated: false)
        }

    }

}
