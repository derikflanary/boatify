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
    var store = AppState.sharedStore
    var session: SPTSession?
    var player = SPTAudioStreamingController.sharedInstance()
    
    var audioRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?
    var timer: NSTimer?
    var progressTimer: NSTimer?
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5
    
    var midVolume: Double {
        return (maxVolume + minVolume) / 2
    }
    
    
    // MARK: - Interface properties
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var playlistsDataSource: PlaylistsDataSource!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hidden = true
        spotifyLoginButton.hidden = true
        player.delegate = self
        player.playbackDelegate = self
        playlistsDataSource.delegate = self
        let command = MPRemoteCommandCenter.sharedCommandCenter()
        command.pauseCommand.enabled = true
        command.pauseCommand.addTarget(self, action: #selector(playPauseTapped))
        command.playCommand.addTarget(self, action: #selector(playPauseTapped))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    func animateInBottomView() {
        bottomViewHeightConstraint.constant = 44
        UIView.animateWithDuration(0.5) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func animateOutBottomView() {
        bottomViewHeightConstraint.constant = 0
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
        if averagePower < -30 {
            volume = minVolume
        } else if averagePower < -22.5 {
            volume = midVolume
        } else {
            volume = maxVolume
        }
        spotifyService.update(volume)
        print("average: \(averagePower)")
    }
    
    
    // MARK: - Remote command
    
    func playPauseTapped() {
        if player.isPlaying {
            stopRecording()
        } else {
            startRecording()
            startTrackingProgress()
        }
        spotifyService.updateIsPlaying()
    }

    // MARK: - Track progress
    func updateProgress() {
        let percent = spotifyService.trackProgress()
        progressView.setProgress(percent, animated: true)
    }
    
    func startTrackingProgress() {
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    
    func stopTrackingProgress() {
        progressTimer?.invalidate()
    }
    
    // MARK: - Interface actions
    
    @IBAction func spotifyLoginTapped(sender: AnyObject) {
        spotifyService.loginToSpotify()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "PresentSettings", let destinationNavigationController = segue.destinationViewController as? UINavigationController, targetController = destinationNavigationController.topViewController as? SettingsViewController else { return }
        targetController.delegate = self
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
        trackNameLabel.text = trackName
        artistLabel.text = artistName
        animateInBottomView()
        startTrackingProgress()
    }

}


// MARK: - Table view delegate

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPlaylistDetails", sender: self)
        let playlist: SPTPartialPlaylist = playlistsDataSource.playlists[indexPath.row]
        
        store.dispatch(spotifyService.select(playlist))
        store.dispatch(spotifyService.getPlaylistDetails)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
}


// MARK: - Playlist cell delegate

extension ViewController: PlaylistCellDelegate {
    
    func play(uri: NSURL) {
        spotifyService.play(uri: uri)
        self.startRecording()
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
        guard let session = state.session else { return }
        self.session = session
        audioRecorder = state.audioRecorder
        minVolume = state.minVolume
        maxVolume = state.maxVolume
        
        switch state.viewState {
        case .preLoggedIn:
            if !player.loggedIn && session.isValid() {
                store.dispatch(spotifyService.loginPlayer)
            } else if !session.isValid() && SPTAuth.defaultInstance().hasTokenRefreshService {
                store.dispatch(spotifyService.refresh(session))
            } else {
                spotifyLoginButton.hidden = false
            }
        case .viewing:
            dismissBanner()
            tableView.hidden = false
            playlistsDataSource.playlists = state.playlists
            if state.playlistImages.count != 0 {
                playlistsDataSource.images = state.playlistImages
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
        case let .loading(message):
            showLoadingBanner(message)
            spotifyLoginButton.hidden = true
        case let .error(message):
            showErrorBanner(message)
        }
    }
    
}


