//
//  PlaylistDetailViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import ReSwift
import AVFoundation

class PlaylistDetailViewController: UIViewController {
    
    var store = AppState.sharedStore
    var trackURIs = [NSURL]()
    var player = SPTAudioStreamingController.sharedInstance()
    var audioRecorder: AVAudioRecorder?
    var timer: NSTimer?
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5
    
    var midVolume: Double {
        return (maxVolume + minVolume) / 2
    }

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tracksDataSource: TracksDataSource!
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    
    // MARK: - Recording
    
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

}


// MARK: - Tableview delgate

extension PlaylistDetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = tracksDataSource.tracks[indexPath.row]
        let options = SPTPlayOptions()
        options.trackIndex = Int32(indexPath.row)
        player.setVolume(minVolume, callback: nil)
        player.playURIs(trackURIs, withOptions: options, callback: nil)
        startRecording()
    }
}


// MARK: - Store subscriber

extension PlaylistDetailViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        audioRecorder = state.audioRecorder
        minVolume = state.minVolume
        maxVolume = state.maxVolume
        
        trackURIs = state.tracks.map { $0.playableUri }
        tracksDataSource.tracks = state.tracks
        tableView.reloadData()
    }
    
}
