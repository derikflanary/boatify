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
import MediaPlayer

class PlaylistDetailViewController: UIViewController {
    
    typealias StoreSubscriberStateType = AppState
    var store = AppState.sharedStore
    var spotifyService = SpotifyService()
    var musicService = MusicService()
    var musicState = MusicState.none
    
    var trackURIs = [URL]()
    var player = SPTAudioStreamingController.sharedInstance()
    var audioRecorder: AVAudioRecorder?
    var timer: Timer?
    var maxVolume: Double = 1.0
    var minVolume: Double = 0.5
    
    var midVolume: Double {
        return (maxVolume + minVolume) / 2
    }

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tracksDataSource: TracksDataSource!
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    
    // MARK: - Recording
    
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
    }

}


// MARK: - Tableview delgate

extension PlaylistDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch musicState {
        case .spotify:
            let track = tracksDataSource.spotifyTracks[indexPath.row]
            player?.setVolume(minVolume, callback: nil)
            player?.playSpotifyURI(track.playableUri.absoluteString, startingWith: UInt(indexPath.row), startingWithPosition: 0, callback: { error in
                if let error = error {
                    print(error)
                }
            })
            startRecording()
            store.dispatch(spotifyService.select(track))
        case .local:
            let track = tracksDataSource.localTracks[indexPath.row]
            store.dispatch(musicService.select(track))
            store.dispatch(musicService.playTrack)
        case .none:
            break
        }
    }
}


// MARK: - Store subscriber

extension PlaylistDetailViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        audioRecorder = state.audioRecorder
        minVolume = state.minVolume
        maxVolume = state.maxVolume
        musicState = state.musicState
        tracksDataSource.musicState = state.musicState
        
        switch musicState {
        case .spotify:
            trackURIs = state.spotifyState.tracks.map { $0.playableUri }
            tracksDataSource.spotifyTracks = state.spotifyState.tracks
            tracksDataSource.selectedSpotifyTrack = state.spotifyState.selectedTrack
            tableView.reloadData()
            title = state.spotifyState.selectedPlaylist?.name
        case .local:
            guard let tracks = state.localMusicState.selectedPlaylist?.items else { return }
            tracksDataSource.localTracks = tracks
            tracksDataSource.currentLocalTrack = state.localMusicState.currentTrack
            tableView.reloadData()
            title = state.localMusicState.selectedPlaylist?.name
            break
        case .none:
            break
        }
    }
    
}
