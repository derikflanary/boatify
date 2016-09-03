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
    var timer: NSTimer?
    var progressTimer: NSTimer?
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5
    
    var midVolume: Double {
        return (maxVolume + minVolume) / 2
    }
    
    var blurView: UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
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
    @IBOutlet var playBackView: PlaybackView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var bottomView: PlaybackView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hidden = true
        player.delegate = self
        player.playbackDelegate = self
        playlistsDataSource.delegate = self
        bottomView.addGestureRecognizer(tapGesture)
        tableView.tableFooterView = UIView()
        bottomView = playBackView
        
        let command = MPRemoteCommandCenter.sharedCommandCenter()
        command.nextTrackCommand.enabled = true
        command.previousTrackCommand.enabled = true
        command.togglePlayPauseCommand.enabled = true
        command.playCommand.enabled = true
        command.playCommand.addTarget(self, action: #selector(playPauseTapped))
        command.pauseCommand.addTarget(self, action: #selector(playPauseTapped))
        command.togglePlayPauseCommand.addTarget(self, action: #selector(playPauseTapped))
        command.nextTrackCommand.addTarget(self, action: #selector(nextTrackTapped))
        command.previousTrackCommand.addTarget(self, action: #selector(previousTrackTapped))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
        spotifyLoginButton.layer.cornerRadius = 5
        spotifyLoginButton.clipsToBounds = true
        playLocalButton.layer.cornerRadius = 5
        playLocalButton.clipsToBounds = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    
    // MARK: - Bottom view animations
    
    func animateInBottomView() {
        bottomViewBottomConstraint.constant = 0
        UIView.animateWithDuration(0.5) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func animateOutBottomView() {
        bottomViewBottomConstraint.constant = -60
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - Recording
    
    func requestPermissionToRecord() {
        if AVAudioSession.sharedInstance().recordPermission() == .Granted {
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
        audioRecorder.meteringEnabled = true
        audioRecorder.record()
        audioRecorder.updateMeters()
        startMeter()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
    }
    
    func startMeter() {
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    func updateMeter() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        let averagePower = audioRecorder.averagePowerForChannel(0)
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
            if player.isPlaying {
                stopRecording()
            } else {
                startRecording()
                startTrackingProgress()
            }
            spotifyService.updateIsPlaying()
        case .local:
            switch playback {
            case .playing:
                stopRecording()
                stopTrackingProgress()
            case .paused:
                startRecording()
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
            bottomView.progressView.setProgress(percent, animated: true)
        case .local:
            bottomView.progressView.setProgress(Float(trackPercent), animated: true)
            store.dispatch(musicService.updateTrackProgress)
        case .none:
            break
        }
    }
    
    func startTrackingProgress() {
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func stopTrackingProgress() {
        progressTimer?.invalidate()
    }
    
    
    // MARK: - Interface actions
    
    @IBAction func spotifyLoginTapped(sender: AnyObject) {
        store.dispatch(spotifyService.selectSpotify())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "PresentSettings", let destinationNavigationController = segue.destinationViewController as? UINavigationController, targetController = destinationNavigationController.topViewController as? SettingsViewController else { return }
        targetController.delegate = self
    }

    @IBAction func playLocalButtonTapped() {
        store.dispatch(musicService.selectLocal())
    }

    @IBAction func switchMusicStateTapped(sender: AnyObject) {
        stopRecording()
        stopTrackingProgress()
        store.dispatch(settingsService.resetMusicState())
    }
    
    // MARK: - Background blur
    
    func blurBackground() {
        if visualEffectView.alpha == 0 {
            UIView.animateWithDuration(1.0, animations: {
                self.visualEffectView.alpha = 1.0
            })
        }
    }
    
    func removeBlurFromBackground() {
        spotifyLoginButton.alpha = 0
        playLocalButton.alpha = 0
        spotifyLogo.alpha = 0
        spotifyLoginButton.hidden = false
        playLocalButton.hidden = false
        spotifyLogo.hidden = false
        if visualEffectView.alpha == 1 {
            UIView.animateWithDuration(1.0, animations: {
                self.visualEffectView.alpha = 0.0
            })
        }
        UIView.animateWithDuration(1.0, animations: {
            self.spotifyLoginButton.alpha = 1
            self.playLocalButton.alpha = 1
            self.spotifyLogo.alpha = 1
        })
    }
}


// MARK: Streaming delegate

extension ViewController: SPTAudioStreamingDelegate {

    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        store.dispatch(spotifyService.getPlaylists())
        player.setVolume(minVolume, callback: nil)
        requestPermissionToRecord()
    }
    
}

extension ViewController: SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        guard let trackName = player.currentTrackMetadata[SPTAudioStreamingMetadataTrackName] as? String, artistName = player.currentTrackMetadata[SPTAudioStreamingMetadataArtistName] as? String else { return }
        player.currentTrackDuration
        bottomView.trackLabel.text = trackName
        bottomView.artistLabel.text = artistName
        startTrackingProgress()
    }

}


// MARK: - Table view delegate

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPlaylistDetails", sender: self)
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52
    }
    
}


// MARK: - Playlist cell delegate

extension ViewController: PlaylistCellDelegate {
    
    func playSpotify(uri: NSURL) {
        spotifyService.play(uri: uri)
        startRecording()
    }
    
    func playLocal(playlist: MPMediaPlaylist) {
        store.dispatch(musicService.select(playlist))
        store.dispatch(musicService.playPlaylist)
        startRecording()
        startTrackingProgress()
    }
    
}


extension ViewController: SettingsDelegate {
    
    func volumeChanged(minVolume: Double, maxVolume: Double) {
        self.minVolume = minVolume
        self.maxVolume = maxVolume
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
            guard let session = state.spotifyState.session else { return }
            self.session = session
            switch state.viewState {
            case .preLoggedIn:
                if !player.loggedIn && session.isValid() {
                    store.dispatch(spotifyService.loginPlayer)
                } else if !session.isValid() && SPTAuth.defaultInstance().hasTokenRefreshService {
                    store.dispatch(spotifyService.refresh(session))
                } else {
                    spotifyService.loginToSpotify()
                }
            case .viewing:
                dismissBanner()
                tableView.hidden = false
                spotifyLoginButton.hidden = true
                playLocalButton.hidden = true
                spotifyLogo.hidden = true
                animateInBottomView()
                playlistsDataSource.spotifyPlaylists = state.spotifyState.playlists
                if state.spotifyState.playlistImages.count != 0 {
                    playlistsDataSource.images = state.spotifyState.playlistImages
                    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                }
                if playlistsDataSource.spotifyPlaylists.count == 0 {
                    tableView.backgroundView = emptyStateView
                }
            case let .loading(message):
                showLoadingBanner(message)
                spotifyLoginButton.hidden = true
                playLocalButton.hidden = true
                spotifyLogo.hidden = true
                blurBackground()
            case let .error(message):
                showErrorBanner(message)
            }
        case .local:
            tableView.hidden = false
            spotifyLoginButton.hidden = true
            playLocalButton.hidden = true
            spotifyLogo.hidden = true
            blurBackground()
            animateInBottomView()
            if MPMediaLibrary.authorizationStatus() == .Authorized && !state.localMusicState.playlistsLoaded {
                store.dispatch(musicService.getPlaylists())
                requestPermissionToRecord()
            } else if MPMediaLibrary.authorizationStatus() != .Authorized {
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
            tableView.hidden = true
            removeBlurFromBackground()
            animateOutBottomView()
            do {
                try player.stop()
            } catch {
                print(error)
            }
        }
    }
    
}


