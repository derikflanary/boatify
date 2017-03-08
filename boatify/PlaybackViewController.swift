//
//  PlaybackViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/17/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor
import MediaPlayer

class PlaybackViewController: UIViewController {
    
    // MARK: - Properties
    
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
    var player = SPTAudioStreamingController.sharedInstance()
    var progressTimer: Timer?
    var spotifyService = SpotifyService()
    
    
    // MARK: - Interface properties
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        player?.delegate = self
        player?.playbackDelegate = self
        let command = MPRemoteCommandCenter.shared()
        command.nextTrackCommand.isEnabled = true
        command.previousTrackCommand.isEnabled = true
        command.togglePlayPauseCommand.isEnabled = true
        command.playCommand.isEnabled = true
        command.playCommand.addTarget(self, action: #selector(playPauseRemoteTapped))
        command.pauseCommand.addTarget(self, action: #selector(playPauseRemoteTapped))
        command.togglePlayPauseCommand.addTarget(self, action: #selector(playPauseTapped))
        command.nextTrackCommand.addTarget(self, action: #selector(nextTrackTapped))
        command.previousTrackCommand.addTarget(self, action: #selector(previousTrackTapped))
    }
    
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
        switch core.state.musicState {
        case .spotify:
            spotifyService.advanceToNextTrack()
        case .local:
            core.fire(command: AdvanceToNextLocalTrack())
        case .none:
            break
        }
    }
    
    @IBAction func previousButtonTapped() {
        switch core.state.musicState {
        case .spotify:
            spotifyService.advanceToPreviousTrack()
        case .local:
            core.fire(command: AdvanceToPreviousLocalTrack())
        case .none:
            break
        }
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
        switch core.state.musicState {
        case .spotify:
            switch core.state.spotifyState.shuffle {
            case .off:
                core.fire(command: ShuffleSpotifyPlaylist())
            case .on:
                core.fire(command: UnshuffleSpotifyPlaylist())
            }
        case .local:
            switch core.state.localMusicState.shuffle {
            case .off:
                core.fire(command: EnableLocalShuffle())
            case .on:
                core.fire(command: DisableLocalShuffle())
            }
        case .none:
            break
        }

    }
    
    @IBAction func expandButtonTapped() {
    }
    
    
    // MARK: - Remote command
    
    func playPauseRemoteTapped() {
        switch core.state.musicState {
        case .spotify:
            guard let player = player else { return }
            if (player.playbackState.isPlaying) {
                core.fire(event: RecordingStopped())
            } else {
                core.fire(event: RecordingStarted())
                startTrackingProgress()
                
            }
            spotifyService.updateIsPlaying()
        case .local:
            switch core.state.localMusicState.playback {
            case .playing:
                core.fire(event: RecordingStopped())
                stopTrackingProgress()
                
            case .paused:
                core.fire(event: RecordingStarted())
                startTrackingProgress()
                
            default:
                break
            }
            core.fire(command: UpdateLocalPlayPause())
        case .none:
            break
        }
    }
    
    func nextTrackTapped() {
        switch core.state.musicState {
        case .spotify:
            spotifyService.advanceToNextTrack()
        case .local:
            core.fire(command: AdvanceToNextLocalTrack())
        case .none:
            break
        }
    }
    
    func previousTrackTapped() {
        switch core.state.musicState {
        case .spotify:
            spotifyService.advanceToPreviousTrack()
        case .local:
            core.fire(command: AdvanceToPreviousLocalTrack())
        case .none:
            break
        }
    }

    
    // MARK: - Track progress
    
    
    func startTrackingProgress() {
        progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func stopTrackingProgress() {
        progressTimer?.invalidate()
    }
    
    func updateProgress() {
        switch core.state.musicState {
        case .spotify:
            let percent = spotifyService.trackProgress()
            progressView.setProgress(percent, animated: true)
            if let currentTrack = spotifyService.currentTrackData() {
                trackLabel.text = currentTrack.name
                artistLabel.text = currentTrack.artistName
            }
        case .local:
            core.fire(command: UpdateLocalTrackProgress())
        case .none:
            break
        }
    }

}



// MARK: Streaming delegate

extension PlaybackViewController: SPTAudioStreamingDelegate {
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        core.fire(command: GetSpotifyPlaylists())
        player?.setVolume(core.state.recorderState.volume.min, callback: nil)
        core.fire(command: RequestPermissionToRecord())
    }
    
}

extension PlaybackViewController: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        guard let trackName = player?.metadata.currentTrack?.name, let artist = player?.metadata.currentTrack?.artistName else { return }
        trackLabel.text = trackName
        artistLabel.text = artist
        startTrackingProgress()
    }
    
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
                shuffleButton.setImage(#imageLiteral(resourceName: "shuffleOn"), for: .normal)
            } else {
                shuffleButton.setImage(#imageLiteral(resourceName: "shuffleOff"), for: .normal)
            }
            
            
        case .none:
            stopTrackingProgress()
            
        }
    }
}
