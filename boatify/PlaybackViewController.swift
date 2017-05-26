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
import Hero

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
    var recordingTimer: Timer?
    var spotifyService = SpotifyService()
    var timerController = TimerController.sharedInstance
    
    
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
        playPauseButton.imageView?.contentMode = .scaleToFill
        nextButton.imageView?.contentMode = .scaleToFill
        previousButton.imageView?.contentMode = .scaleToFill
        shuffleButton.imageView?.contentMode = .scaleToFill
        
        Hero.shared.setDefaultAnimationForNextTransition(.cover(direction: .up))
        
        let command = MPRemoteCommandCenter.shared()
        command.nextTrackCommand.isEnabled = true
        command.previousTrackCommand.isEnabled = true
        command.playCommand.isEnabled = true
        command.pauseCommand.isEnabled = true
        command.enableLanguageOptionCommand.isEnabled = true
        command.playCommand.addTarget(self, action: #selector(playPauseRemoteTapped))
        command.pauseCommand.addTarget(self, action: #selector(playPauseRemoteTapped))
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
        nextTrackTapped()
    }
    
    @IBAction func previousButtonTapped() {
        previousTrackTapped()
    }
    
    @IBAction func playPauseTapped() {
        playPauseRemoteTapped()
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
        performSegue(withIdentifier: "expandPlayback", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? ExpandedPlaybackViewController else { return }
        guard let artist = artistLabel.text, let track = trackLabel.text else { return }
        destinationVC.artist = artist
        destinationVC.track = track
        switch core.state.musicState {
        case .local:
            destinationVC.progress = progressView.progress
        case .spotify:
            break
        case .none:
            break
        }
    }
    
    // MARK: - Remote command
    
    func playPauseRemoteTapped() {
        switch core.state.musicState {
        case .spotify:
            switch core.state.spotifyState.playback {
            case .playing:
                core.fire(command: PauseSpotify())
            case .paused:
                core.fire(command: PlaySpotify())
            case .stopped:
                break
            }
        case .local:
            switch core.state.localMusicState.playback {
            case .playing:
                core.fire(event: Updated(item: Playback.paused))
                stopTracking()
            case .paused:
                core.fire(event: Updated(item: Playback.playing))
                startTracking()
            case .stopped:
                break
            }
        case .none:
            break
        }
    }
    
    func nextTrackTapped() {
        switch core.state.musicState {
        case .spotify:
            core.fire(command: AdvanceToNextSpotifyTrack())
        case .local:
            core.fire(command: AdvanceToNextLocalTrack())
        case .none:
            break
        }
    }
    
    func previousTrackTapped() {
        switch core.state.musicState {
        case .spotify:
            core.fire(command: AdvanceToPreviousSpotifyTrack())
        case .local:
            core.fire(command: AdvanceToPreviousLocalTrack())
        case .none:
            break
        }
    }

    
    // MARK: - Track progress
    
    func startTracking() {
        startTrackingProgress()
        startMeter()
    }
    
    func stopTracking() {
        stopTrackingProgress()
        stopMeter()
    }
    
    
    func startTrackingProgress() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        core.fire(event: TrackingProgress())
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
    
    func startMeter() {
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
        core.fire(event: RecordingStarted())
    }
    
    func stopMeter() {
        recordingTimer?.invalidate()
        core.fire(event: RecordingStopped())
    }
    
    func updateMeter() {
        core.fire(command: UpdateRecording())
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
        startTracking()
    }
    
}


extension PlaybackViewController: Subscriber {
    
    func update(with state: AppState) {
        if state.recorderState.shouldStartRecording {
            startMeter()
        }
        
        switch state.musicState {
        case .local:
            trackLabel.text = state.localMusicState.selectedTrack?.title
            artistLabel.text = state.localMusicState.selectedTrack?.artist
            if let selectedTrack = state.localMusicState.selectedTrack, let title = selectedTrack.title, let artist = selectedTrack.artist {
                
                let songInfo = [ MPMediaItemPropertyTitle: title,
                                 MPMediaItemPropertyArtist: artist ]
                MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo

            }
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
            progressView.setProgress(Float(state.localMusicState.trackPercent), animated: true)
            if state.localMusicState.shouldStartTrackingProgress {
                startTrackingProgress()
            }
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
            progressView.setProgress(0, animated: false)
        }
    }
}
