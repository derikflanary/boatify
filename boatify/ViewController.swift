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
            startRecording()
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                if allowed {
                    print("allowed")
                    self.startRecording()
                } else {
                    print("failed to record")
                }
            }
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
            
            do {
                audioRecorder = try AVAudioRecorder(URL: soundURL, settings: settings)
                guard let audioRecorder = audioRecorder else { return }
                audioRecorder.delegate = self
                audioRecorder.meteringEnabled = true
                audioRecorder.record()
                audioRecorder.updateMeters()
                startMeter()
                
            } catch {
                print(error)
            }

        } catch {
            print(error)
        }
    }
    
    func startMeter() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
    }
    
    func updateMeter() {
        guard let audioRecorder = audioRecorder else { return }
        audioRecorder.updateMeters()
        let averagePower = audioRecorder.averagePowerForChannel(0)
        if averagePower < -30 {
            player.setVolume(0.5) { error in }
        } else if averagePower < -22.5 {
            player.setVolume(0.75) { error in}
        } else {
            player.setVolume(1.0) { error in }
        }
        print("average: \(averagePower)")
        print(player.volume)
    }
    
    
    // MARK: - Remote command
    
    func playPauseTapped() {
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
        spotifyLoginButton.hidden = true
        tableView.hidden = false
        
        requestPermissionToRecord()
    }
    
}


extension ViewController: AVAudioRecorderDelegate {
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let playlist = playlistsDataSource.playlists[indexPath.row]
        store.dispatch(spotifyService.selectPlaylist(playlist))
    }
    
}

extension ViewController: PlaylistCellDelegate {
    
    func play(uri: NSURL) {
        player.playURI(uri, callback: nil)
    }
}


// MARK: - Store subscriber

extension ViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        guard let session = state.session else { return }
        self.session = session

        if !player.loggedIn && session.isValid() {
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
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
    }
}


