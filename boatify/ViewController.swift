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
    var store = AppState.sharedStore
    var session: SPTSession?
    var player = SPTAudioStreamingController.sharedInstance()
    
    var audioRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?
    var timer: NSTimer?
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5
    
    var midVolume: Double {
        return (maxVolume + minVolume) / 2
    }
    
    
    // MARK: - Interface properties
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var playlistsDataSource: PlaylistsDataSource!
    
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.hidden = true
        player.delegate = self
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
    
    
    // MARK: - Recording
    
    func requestPermissionToRecord() {
        if AVAudioSession.sharedInstance().recordPermission() == .Granted {
            print("already granted")
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission({ allowed in
                if allowed {
                    print("allowed")
                } else {
                    print("failed to record")
                }
            })
        }
    }
    
    func startRecording() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            
            let fileManager = NSFileManager.defaultManager()
            let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let documentDirectory = urls[0] as NSURL
            let soundURL = documentDirectory.URLByAppendingPathComponent("sound.caf")
            
            let settings: [String : AnyObject] = [  AVSampleRateKey:44100.0,
                                                    AVNumberOfChannelsKey:1,AVEncoderBitRateKey:12800,
                                                    AVLinearPCMBitDepthKey:16,
                                                    AVEncoderAudioQualityKey:AVAudioQuality.Low.rawValue]
            
            
            audioRecorder = try AVAudioRecorder(URL: soundURL, settings: settings)
            guard let audioRecorder = audioRecorder else { return }
            
            audioRecorder.meteringEnabled = true
            audioRecorder.record()
            audioRecorder.updateMeters()
            startMeter()
        } catch {
            print(error)
        }
    }
    
    func startMeter() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    func updateMeter() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        let averagePower = audioRecorder.averagePowerForChannel(0)
        if averagePower < -30 {
            player.setVolume(minVolume) { error in }
        } else if averagePower < -22.5 {
            player.setVolume(midVolume) { error in }
        } else {
            player.setVolume(maxVolume) { error in }
        }
        print("average: \(averagePower)")
        print(player.volume)
    }
    
    
    // MARK: - Remote command
    
    func playPauseTapped() {
        if player.isPlaying {
            audioRecorder?.stop()
        } else {
            startRecording()
        }
        player.setIsPlaying(!player.isPlaying) { error in
            if error != nil {
                print(error)
            }
        }
    }

    
    // MARK: - Interface actions
    
    @IBAction func spotifyLoginTapped(sender: AnyObject) {
        spotifyService.loginToSpotify()
    }

}


// MARK: Streaming delegate

extension ViewController: SPTAudioStreamingDelegate {

    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        tableView.hidden = false
        player.setVolume(minVolume, callback: nil)
        requestPermissionToRecord()
        dismissBanner()
    }
    
}


// MARK: - Table view delegate

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPlaylistDetails", sender: self)
        let playlist = playlistsDataSource.playlists[indexPath.row]
        store.dispatch(spotifyService.selectPlaylist(playlist))
        store.dispatch(spotifyService.getPlaylistDetails)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
}


// MARK: - Playlist cell delegate

extension ViewController: PlaylistCellDelegate {
    
    func play(uri: NSURL) {
        player.playURIs([uri], withOptions: SPTPlayOptions(), callback: nil)
        self.startRecording()
    }
}


// MARK: - Store subscriber

extension ViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        guard let session = state.session else { return }
        self.session = session
        minVolume = state.minVolume
        maxVolume = state.maxVolume

        if !player.loggedIn && session.isValid() {
            showLoadingBanner("Loading your playlists...")
            spotifyLoginButton.hidden = true
            do {
                try player.startWithClientId(SpotifyService.kClientId)
                player.loginWithAccessToken(session.accessToken)
                store.dispatch(spotifyService.getPlaylistsWithSession(session))
            } catch {
                print(error)
            }
        }
        
        if !session.isValid() && SPTAuth.defaultInstance().hasTokenRefreshService {
            store.dispatch(spotifyService.refresh(session))
        }
        
        playlistsDataSource.playlists = state.playlists
        if state.playlistImages.count != 0 {
            playlistsDataSource.images = state.playlistImages
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
}


