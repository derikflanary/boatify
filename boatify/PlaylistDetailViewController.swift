//
//  PlaylistDetailViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor
import AVFoundation
import MediaPlayer
import Hero

class PlaylistDetailViewController: UIViewController {
    
    
    var core = App.sharedCore
    var spotifyService = SpotifyService()
    var musicState = MusicState.none
    var timer: Timer?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tracksDataSource: TracksDataSource!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        switch musicState {
        case .spotify:
            core.fire(event: Reset<SPTPartialPlaylist>())
        case .local:
            core.fire(event: Reset<MPMediaPlaylist>())
        case .none:
            break
        }
        core.remove(subscriber: self)
    }
    
}


// MARK: - Tableview delgate

extension PlaylistDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch musicState {
        case .spotify:
            let track = tracksDataSource.spotifyTracks[indexPath.row]
            
            core.fire(event: Selected(item: track))
            core.fire(command: PlayLocalSelectedPlaylist())
            core.fire(event: RecordingStarted())
        case .local:
            let track = tracksDataSource.localTracks[indexPath.row]
            core.fire(event: Selected(item: track))
            core.fire(command: PlaySelectedLocalTrack())
        case .none:
            break
        }
    }
}


// MARK: - Subscriber

extension PlaylistDetailViewController: Subscriber {
    
    func update(with state: AppState) {
        musicState = state.musicState
        tracksDataSource.musicState = state.musicState
        
        switch musicState {
        case .spotify:
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
