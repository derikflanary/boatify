//
//  ViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import ReSwift
import AVFoundation
import MediaPlayer
import Hero

class MainViewController: UIViewController {

    // MARK: - Properties
    
    let spotifyService = SpotifyService()
    let recordingService = RecordingService()
    let settingsService = SettingsService()
    let musicService = MusicService()
    var musicState = MusicState.none
    var store = AppState.sharedStore
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
        store.subscribe(self)
        spotifyLoginButton.layer.cornerRadius = 5
        spotifyLoginButton.clipsToBounds = true
        playLocalButton.layer.cornerRadius = 5
        playLocalButton.clipsToBounds = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
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
                store.dispatch(recordingService.stopRecording())
                
            } else {
                store.dispatch(recordingService.startRecording())
                startTrackingProgress()
                
            }
            spotifyService.updateIsPlaying()
        case .local:
            switch playback {
            case .playing:
                store.dispatch(recordingService.stopRecording())
                stopTrackingProgress()
                
            case .paused:
                store.dispatch(recordingService.startRecording())
                startTrackingProgress()
        
            default:
                break
            }
            store.dispatch(musicService.updatePlayPause)
            
        case .none:
            break
        }
    }
    
    func nextTrackTapped() {
        switch musicState {
        case .spotify:
            spotifyService.advanceToNextTrack()
        case .local:
            store.dispatch(musicService.advanceToNextTrack)
        case .none:
            break
        }
    }
    
    func previousTrackTapped() {
        switch musicState {
        case .spotify:
            spotifyService.advanceToPreviousTrack()
        case .local:
            store.dispatch(musicService.advanceToPreviousTrack())
        case .none:
            break
        }
    }

    
    // MARK: - Track progress
    
    func updateProgress() {
        switch musicState {
        case .spotify:
            let percent = spotifyService.trackProgress()
//            bottomView.progressView.setProgress(percent, animated: true)
        case .local:
//            bottomView.progressView.setProgress(Float(trackPercent), animated: true)
            store.dispatch(musicService.updateTrackProgress)
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
        store.dispatch(spotifyService.selectSpotify())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "PresentSettings", let destinationNavigationController = segue.destination as? UINavigationController, let targetController = destinationNavigationController.topViewController as? SettingsViewController else { return }
        targetController.delegate = self
    }

    @IBAction func playLocalButtonTapped() {
        store.dispatch(musicService.selectLocal())
    }

    @IBAction func switchMusicStateTapped(_ sender: AnyObject) {
        store.dispatch(recordingService.stopRecording())
        stopTrackingProgress()
        store.dispatch(settingsService.resetMusicState())
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
        store.dispatch(spotifyService.getPlaylists)
        player?.setVolume(minVolume, callback: nil)
        store.dispatch(recordingService.requestPermissionToRecord)
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
            store.dispatch(spotifyService.select(playlist))
            store.dispatch(spotifyService.getPlaylistDetails)
        case .local:
            guard let playlist = playlistsDataSource.localPlaylists[indexPath.row] as? MPMediaPlaylist else { break }
            store.dispatch(musicService.select(playlist))
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
        store.dispatch(Play(item: playlist))
        spotifyService.play(uri: playlist.playableUri)
//        bottomView.paused = false
        store.dispatch(recordingService.startRecording())
    }
    
    func playLocal(_ playlist: MPMediaPlaylist) {
        store.dispatch(Play(item: playlist))
        store.dispatch(musicService.playPlaylist)
        store.dispatch(recordingService.startRecording())
        startTrackingProgress()
//        bottomView.paused = false
    }
    
}


extension MainViewController: SettingsDelegate {
    
    func volumeChanged(_ minVolume: Double, maxVolume: Double) {
        self.minVolume = minVolume
        self.maxVolume = maxVolume
    }
}


// MARK: - Playback view delegate



// MARK: - Store subscriber

extension MainViewController: StoreSubscriber {
    
    func newState(state: AppState) {
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
                    spotifyService.loginToSpotify()
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
                store.dispatch(musicService.getPlaylists())
                store.dispatch(recordingService.requestPermissionToRecord)
            } else if MPMediaLibrary.authorizationStatus() != .authorized {
                MPMediaLibrary.requestAuthorization({ (status) in
                    self.store.dispatch(self.musicService.getPlaylists())
                    self.store.dispatch(self.recordingService.requestPermissionToRecord)
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


