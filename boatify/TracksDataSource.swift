//
//  TracksDataSource.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import MediaPlayer

class TracksDataSource: NSObject, UITableViewDataSource {
    
    var spotifyTracks = [SPTPartialTrack]()
    var localTracks = [MPMediaItem]()
    var selectedSpotifyTrack: SPTPartialTrack?
    var currentLocalTrack: MPMediaItem?
    var musicState = MusicState.none
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch musicState {
        case .spotify:
            return spotifyTracks.count
        case .local:
            return localTracks.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as TrackCell
        
        switch musicState {
        case .spotify:
            let track = spotifyTracks[indexPath.row]
            cell.configureSpotify(track, selectedTrack: selectedSpotifyTrack)
        case .local:
            let track = localTracks[indexPath.row]
            cell.configureLocal(track, selectedTrack: currentLocalTrack)
        case .none:
            break
        }
        return cell
    }
    
}
