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

class ViewController: UIViewController {

    // MARK: -  Properties
    
    let spotifyService = SpotifyService()
    var store = AppState.sharedStore
    var session: SPTSession?
    var player = SPTAudioStreamingController.sharedInstance()
    
    var audioRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?
    var timer: NSTimer?
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
    
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }

    func login() {
        guard let session = session else { return }
        
        do {
            try player.startWithClientId(SpotifyService.kClientId)
            player.loginWithAccessToken(session.accessToken)
            
        } catch {
            print(error)
        }
        print("login success")
    }
    
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
        let volume: Double = -15 / Double(averagePower)
        print("average: \(averagePower)")
        player.setVolume(volume) { error in }
        print(player.volume)
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
        requestPermissionToRecord()
        
        guard let url = NSURL(string: "spotify:track:58s6EuEYJdlb0kO7awm3Vp") else { return }
        
        player.playURIs([url], withOptions: SPTPlayOptions()) { error in
            if error != nil {
                print(error)
            }
        }
    }
    
}


extension ViewController: AVAudioRecorderDelegate {
    
}


// MARK: - Store subscriber

extension ViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        guard let session = state.session else { return }
        self.session = session
        login()
    }
}


