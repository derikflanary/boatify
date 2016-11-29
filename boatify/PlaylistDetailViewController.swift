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
    var recordingService = RecordingService()
    var musicState = MusicState.none
    var timer: Timer?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tracksDataSource: TracksDataSource!
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        switch musicState {
        case .spotify:
            store.dispatch(Reset<SPTPartialPlaylist>())
        case .local:
            store.dispatch(Reset<MPMediaPlaylist>())
        case .none:
            break
        }
        store.unsubscribe(self)
    }
    
}


// MARK: - Tableview delgate

extension PlaylistDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch musicState {
        case .spotify:
            let track = tracksDataSource.spotifyTracks[indexPath.row]
            store.dispatch(spotifyService.select(track))
            store.dispatch(spotifyService.playSelectedPlaylist(at: indexPath.row))
            store.dispatch(recordingService.startRecording())
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
        musicState = state.musicState
        tracksDataSource.musicState = state.musicState
        
        switch musicState {
        case .spotify:
            tracksDataSource.spotifyTracks = state.spotifyState.tracks
            tracksDataSource.selectedSpotifyTrack = state.spotifyState.selectedTrack
            tableView.reloadData()
            title = state.spotifyState.selectedPlaylist?.name
            spotifyService.update(state.recorderState.volume.current)
        case .local:
            guard let tracks = state.localMusicState.selectedPlaylist?.items else { return }
            tracksDataSource.localTracks = tracks
            tracksDataSource.currentLocalTrack = state.localMusicState.currentTrack
            tableView.reloadData()
            title = state.localMusicState.selectedPlaylist?.name
            store.dispatch(musicService.update(Float(state.recorderState.volume.current)))
            break
        case .none:
            break
        }
    }
    
}
