//
//  ViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor
import AVFoundation
import MediaPlayer
import Hero

class MainViewController: UIViewController {

    // MARK: - Properties
    
    let spotifyService = SpotifyService()
    var musicState = MusicState.none
    var core = App.sharedCore
    var session: SPTSession?
    var player = SPTAudioStreamingController.sharedInstance()
    
    var selectedPlaylist: MPMediaItemCollection?
    var trackPercent: Double = 0.0
    var playback = Playback.stopped
    
    var audioRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?
    var timer: Timer?
    var progressTimer: Timer?
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5
    
    var midVolume: Double {
        return (maxVolume + minVolume) / 2
    }
    
    var blurView: UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        return UIVisualEffectView(effect: blurEffect)
    }
    
    
    // MARK: - Interface properties
    
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var spotifyLogo: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var spotifyLoginButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var playlistsDataSource: PlaylistsDataSource!
    @IBOutlet weak var playLocalButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        tableView.isHidden = true
        player?.delegate = self
        player?.playbackDelegate = self
        playlistsDataSource.delegate = self
        tableView.tableFooterView = UIView()
        visualEffectView.effect = nil
        
        navigationController?.heroNavigationAnimationType = .fade
        Hero.shared.disableDefaultAnimationForNextTransition()
        
        let command = MPRemoteCommandCenter.shared()
        command.nextTrackCommand.isEnabled = true
        command.previousTrackCommand.isEnabled = true
        command.togglePlayPauseCommand.isEnabled = true
        command.playCommand.isEnabled = true
        command.playCommand.addTarget(self, action: #selector(playPauseTapped))
        command.pauseCommand.addTarget(self, action: #selector(playPauseTapped))
        command.togglePlayPauseCommand.addTarget(self, action: #selector(playPauseTapped))
        command.nextTrackCommand.addTarget(self, action: #selector(nextTrackTapped))
        command.previousTrackCommand.addTarget(self, action: #selector(previousTrackTapped))
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
        spotifyLoginButton.layer.cornerRadius = 5
        spotifyLoginButton.clipsToBounds = true
        playLocalButton.layer.cornerRadius = 5
        playLocalButton.clipsToBounds = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        core.remove(subscriber: self)
    }
    
    
    // MARK: - Bottom view animations
    
    func animateInBottomView() {
        tableView.isHidden = false
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.tableView.alpha = 1.0
            })
        }
    }
    
    func animateOutBottomView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.tableView.alpha = 0.0
            })
        }
    }
    
    
    // MARK: - Remote command
    
    func playPauseTapped() {
        switch musicState {
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
            switch playback {
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
        switch musicState {
        case .spotify:
            spotifyService.advanceToNextTrack()
        case .local:
            core.fire(command: AdvanceToNextLocalTrack())
        case .none:
            break
        }
    }
    
    func previousTrackTapped() {
        switch musicState {
        case .spotify:
            spotifyService.advanceToPreviousTrack()
        case .local:
            core.fire(command: AdvanceToPreviousLocalTrack())
        case .none:
            break
        }
    }

    
    // MARK: - Track progress
    
    func updateProgress() {
        switch musicState {
        case .spotify:
            let percent = spotifyService.trackProgress()
        case .local:
            core.fire(command: UpdateLocalTrackProgress())
        case .none:
            break
        }
    }
    
    func startTrackingProgress() {
        progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func stopTrackingProgress() {
        progressTimer?.invalidate()
    }
    
    
    // MARK: - Interface actions
    
    @IBAction func spotifyLoginTapped(_ sender: AnyObject) {
        core.fire(event: Selected(item: MusicState.spotify))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "PresentSettings", let destinationNavigationController = segue.destination as? UINavigationController, let targetController = destinationNavigationController.topViewController as? SettingsViewController else { return }
        targetController.delegate = self
    }

    @IBAction func playLocalButtonTapped() {
        core.fire(event: Selected(item: MusicState.local))
    }

    @IBAction func switchMusicStateTapped(_ sender: AnyObject) {
        core.fire(event: RecordingStopped())
        stopTrackingProgress()
        core.fire(event: Updated(item: MusicState.none))
        animateOutBottomView()
    }
    
    
    // MARK: - Background blur
    
    func blurBackground() {
        DispatchQueue.main.async {
            if self.visualEffectView.effect == nil {
                UIView.animate(withDuration: 0.5, animations: {
                    self.visualEffectView.effect = UIBlurEffect(style: .light)
                    self.spotifyLoginButton.alpha = 0.0
                    self.playLocalButton.alpha = 0.0
                    self.spotifyLogo.alpha = 0.0

                })
            }
        }

        switch musicState {
        case .spotify:
            title = "Spotify Playlists"
        case .local:
            title = "Local Playlists"
        default:
            title = ""
        }
        navigationController?.isNavigationBarHidden = false
    }
    
    func removeBlurFromBackground() {
        DispatchQueue.main.async {
            if self.visualEffectView.effect != nil {
                UIView.animate(withDuration: 1.0, animations: {
                    self.visualEffectView.effect = nil
                    self.tableView.alpha = 0.0
                    self.spotifyLoginButton.alpha = 1.0
                    self.playLocalButton.alpha = 1.0
                    self.spotifyLogo.alpha = 1.0
                })
            }
        }

    }
}


// MARK: Streaming delegate

extension MainViewController: SPTAudioStreamingDelegate {

    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        core.fire(command: GetSpotifyPlaylists())
        player?.setVolume(minVolume, callback: nil)
        core.fire(command: RequestPermissionToRecord())
    }
    
}

extension MainViewController: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        guard let trackName = player?.metadata.currentTrack?.name, let artist = player?.metadata.currentTrack?.artistName else { return }
//        bottomView.trackLabel.text = trackName
//        bottomView.artistLabel.text = artist
        startTrackingProgress()
    }
    
}


// MARK: - Table view delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPlaylistDetails", sender: self)
        switch musicState {
        case .spotify:
            let playlist: SPTPartialPlaylist = playlistsDataSource.spotifyPlaylists[indexPath.row]
            core.fire(event: Selected(item: playlist))
            core.fire(command: GetSpotifyPlaylistDetails())
        case .local:
            guard let playlist = playlistsDataSource.localPlaylists[indexPath.row] as? MPMediaPlaylist else { break }
            core.fire(event: Selected(item: playlist))
        case .none:
            break
        }
            }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
}


// MARK: - Playlist cell delegate

extension MainViewController: PlaylistCellDelegate {
    
    func playSpotify(_ playlist: SPTPartialPlaylist) {
        core.fire(command: PlaySpotifyPlaylist(playlist: playlist))
        core.fire(event: RecordingStarted())
    }
    
    func playLocal(_ playlist: MPMediaPlaylist) {
        core.fire(event: Selected(item: playlist))
        core.fire(command: PlayLocalSelectedPlaylist())
        core.fire(event: RecordingStarted())
        startTrackingProgress()
    }
    
}


extension MainViewController: SettingsDelegate {
    
    func volumeChanged(_ minVolume: Double, maxVolume: Double) {
        self.minVolume = minVolume
        self.maxVolume = maxVolume
    }
}


// MARK: - Playback view delegate



// MARK: - subscriber

extension MainViewController: Subscriber {
    
    func update(with state: AppState) {
        musicState = state.musicState
        playlistsDataSource.musicState = state.musicState
        
        audioRecorder = state.recorderState.audioRecorder
        minVolume = state.recorderState.volume.min
        maxVolume = state.recorderState.volume.max
        
        switch musicState {
        case .spotify:
            self.session = state.spotifyState.session
            switch state.viewState {
            case .preLoggedIn:
                if state.spotifyState.session == nil {
                    core.fire(command: LoginToSpotify())
                }
            case let .loading(message):
                showLoadingBanner(message)
                blurBackground()
            case .viewing:
                dismissBanner()
                animateInBottomView()
                playlistsDataSource.spotifyPlaylists = state.spotifyState.playlists
                if playlistsDataSource.currentSpotifyPlaylist != state.spotifyState.currentPlaylist {
                    playlistsDataSource.currentSpotifyPlaylist = state.spotifyState.currentPlaylist
                    tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                }
                if state.spotifyState.playlistImages.count != 0 && state.spotifyState.playlistImages != playlistsDataSource.images{
                    playlistsDataSource.images = state.spotifyState.playlistImages
                    tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                }
                if playlistsDataSource.spotifyPlaylists.count == 0 {
                    tableView.backgroundView = emptyStateView
                }
                
            case let .error(message):
                showErrorBanner(message)
            }
        case .local:
            tableView.isHidden = false
            blurBackground()
            animateInBottomView()
            if MPMediaLibrary.authorizationStatus() == .authorized && !state.localMusicState.playlistsLoaded {
                core.fire(command: GetLocalPlaylists())
                core.fire(command: RequestPermissionToRecord())
            } else if MPMediaLibrary.authorizationStatus() != .authorized {
                MPMediaLibrary.requestAuthorization({ (status) in
                    self.core.fire(command: GetLocalPlaylists())
                    self.core.fire(command: RequestPermissionToRecord())
                })
            } else {
                playlistsDataSource.localPlaylists = state.localMusicState.playlists
                playlistsDataSource.currentLocalPlaylist = state.localMusicState.selectedPlaylist
                if playlistsDataSource.localPlaylists.count == 0 {
                    tableView.backgroundView = emptyStateView
                }
                tableView.reloadData()

                trackPercent = state.localMusicState.trackPercent
                playback = state.localMusicState.playback
                if let track = state.localMusicState.currentTrack {
                }
            }
        case .none:
            removeBlurFromBackground()
            navigationController?.isNavigationBarHidden = true
            do {
                try player?.stop()
            } catch {
                print(error)
            }
        }
    }
    
}


