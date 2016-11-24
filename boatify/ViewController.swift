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

class ViewController: UIViewController {

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
    @IBOutlet weak var bottomView: PlaybackView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        tableView.isHidden = true
        player?.delegate = self
        player?.playbackDelegate = self
        playlistsDataSource.delegate = self
        bottomView.addGestureRecognizer(tapGesture)
        tableView.tableFooterView = UIView()
        bottomView.delegate = self
        bottomView.paused = true
        visualEffectView.effect = nil
        
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
        bottomViewBottomConstraint.constant = 0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func animateOutBottomView() {
        bottomViewBottomConstraint.constant = -60
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    // MARK: - Recording
    
    func requestPermissionToRecord() {
        if AVAudioSession.sharedInstance().recordPermission() == .granted {
            store.dispatch(recordingService.setupRecording)
            print("already granted")
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission({ allowed in
                if allowed {
                    self.store.dispatch(self.recordingService.setupRecording)
                    print("allowed")
                } else {
                    print("failed to record")
                }
            })
        }
    }
    
    func startRecording() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        audioRecorder.updateMeters()
        startMeter()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
    }
    
    func startMeter() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    func updateMeter() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        let averagePower = audioRecorder.averagePower(forChannel: 0)
        var volume: Double
        if averagePower < -22.5 {
            volume = minVolume
        } else if averagePower < -15.0 {
            volume = midVolume
        } else {
            volume = maxVolume
        }
        print("average: \(averagePower)")
        switch musicState {
        case .spotify:
            spotifyService.update(volume)
        case .local:
            store.dispatch(musicService.update(Float(volume)))
        case .none:
            break
        }
    }
    
    
    // MARK: - Remote command
    
    func playPauseTapped() {
        switch musicState {
        case .spotify:
            guard let player = player else { return }
            if (player.playbackState.isPlaying) {
                stopRecording()
                bottomView.paused = true
            } else {
                startRecording()
                startTrackingProgress()
                bottomView.paused = false
            }
            spotifyService.updateIsPlaying()
        case .local:
            switch playback {
            case .playing:
                stopRecording()
                stopTrackingProgress()
                bottomView.paused = true
            case .paused:
                startRecording()
                startTrackingProgress()
                bottomView.paused = false
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
            bottomView.progressView.setProgress(percent, animated: true)
        case .local:
            bottomView.progressView.setProgress(Float(trackPercent), animated: true)
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
        stopRecording()
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
                    self.tableView.alpha = 1.0
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
        spotifyLoginButton.alpha = 0
        playLocalButton.alpha = 0
        spotifyLogo.alpha = 0
        spotifyLoginButton.isHidden = false
        playLocalButton.isHidden = false
        spotifyLogo.isHidden = false
        DispatchQueue.main.async {
            if self.visualEffectView.effect != nil {
                UIView.animate(withDuration: 1.0, animations: {
                    self.visualEffectView.effect = nil
                    self.tableView.alpha = 0.0
                })
            }
            UIView.animate(withDuration: 1.0, animations: {
                self.spotifyLoginButton.alpha = 1
                self.playLocalButton.alpha = 1
                self.spotifyLogo.alpha = 1
            })
        }

    }
}


// MARK: Streaming delegate

extension ViewController: SPTAudioStreamingDelegate {

    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        store.dispatch(spotifyService.getPlaylists)
        player?.setVolume(minVolume, callback: nil)
        requestPermissionToRecord()
    }
    
}

extension ViewController: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        guard let trackName = player?.metadata.currentTrack?.name, let artist = player?.metadata.currentTrack?.artistName else { return }
        bottomView.trackLabel.text = trackName
        bottomView.artistLabel.text = artist
        startTrackingProgress()
    }
    
}


// MARK: - Table view delegate

extension ViewController: UITableViewDelegate {
    
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

extension ViewController: PlaylistCellDelegate {
    
    func playSpotify(_ uri: URL) {
        spotifyService.play(uri: uri)
        bottomView.paused = false
        startRecording()
    }
    
    func playLocal(_ playlist: MPMediaPlaylist) {
        store.dispatch(musicService.select(playlist))
        store.dispatch(musicService.playPlaylist)
        startRecording()
        startTrackingProgress()
        bottomView.paused = false
    }
    
}


extension ViewController: SettingsDelegate {
    
    func volumeChanged(_ minVolume: Double, maxVolume: Double) {
        self.minVolume = minVolume
        self.maxVolume = maxVolume
    }
}


// MARK: - Playback view delegate

extension ViewController: PlaybackViewDelegate {
    
    func pausePlayTapped() {
        switch musicState {
        case .spotify:
            if player?.metadata.currentTrack?.uri != nil {
                break
            } else {
                return
            }
        case .local:
            switch playback {
            case .playing, .paused:
                break
            case .stopped:
                return
            }
        case .none:
            return
        }
        playPauseTapped()
    }
    
    func previousTapped() {
        previousTrackTapped()
    }
    
    func nextTapped() {
        nextTrackTapped()
    }
    
    func expandTapped() {
        performSegue(withIdentifier: "PresentPlayback", sender: self)
    }
    
}

// MARK: - Store subscriber

extension ViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        musicState = state.musicState
        playlistsDataSource.musicState = state.musicState
        
        audioRecorder = state.audioRecorder
        minVolume = state.minVolume
        maxVolume = state.maxVolume
        
        switch musicState {
        case .spotify:
            self.session = state.spotifyState.session
            switch state.viewState {
            case .preLoggedIn:
                if let session = session {
                    if !(player?.loggedIn)! && session.isValid() {
                        store.dispatch(spotifyService.loginPlayer)
                    } else if !session.isValid() && SPTAuth.defaultInstance().hasTokenRefreshService {
                        store.dispatch(spotifyService.refresh(session))
                    }
                } else {
                    spotifyService.loginToSpotify()
                }
            case .viewing:
                dismissBanner()
                blurBackground()
                tableView.isHidden = false
                spotifyLoginButton.isHidden = true
                playLocalButton.isHidden = true
                spotifyLogo.isHidden = true
                animateInBottomView()
                playlistsDataSource.spotifyPlaylists = state.spotifyState.playlists
                if state.spotifyState.playlistImages.count != 0 {
                    playlistsDataSource.images = state.spotifyState.playlistImages
                    tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                }
                if playlistsDataSource.spotifyPlaylists.count == 0 {
                    tableView.backgroundView = emptyStateView
                }
            case let .loading(message):
                showLoadingBanner(message)
                spotifyLoginButton.isHidden = true
                playLocalButton.isHidden = true
                spotifyLogo.isHidden = true
                blurBackground()
            case let .error(message):
                showErrorBanner(message)
            }
        case .local:
            tableView.isHidden = false
            spotifyLoginButton.isHidden = true
            playLocalButton.isHidden = true
            spotifyLogo.isHidden = true
            blurBackground()
            animateInBottomView()
            if MPMediaLibrary.authorizationStatus() == .authorized && !state.localMusicState.playlistsLoaded {
                store.dispatch(musicService.getPlaylists())
                requestPermissionToRecord()
            } else if MPMediaLibrary.authorizationStatus() != .authorized {
                MPMediaLibrary.requestAuthorization({ (status) in
                    self.store.dispatch(self.musicService.getPlaylists())
                    self.requestPermissionToRecord()
                })
            } else {
                self.playlistsDataSource.localPlaylists = state.localMusicState.playlists
                if self.playlistsDataSource.localPlaylists.count == 0 {
                    self.tableView.backgroundView = emptyStateView
                }
                tableView.reloadData()

                trackPercent = state.localMusicState.trackPercent
                playback = state.localMusicState.playback
                if let track = state.localMusicState.currentTrack {
                    bottomView.trackLabel.text = track.title
                    bottomView.artistLabel.text = track.artist
                }
            }
        case .none:
            tableView.isHidden = true
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


