//
//  PlaylistsDataSource.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistsDataSource: NSObject, UITableViewDataSource {

    var musicState = MusicState.none
    var spotifyPlaylists = [SPTPartialPlaylist]()
    var localPlaylists = [MPMediaItemCollection]()
    var images = [UIImage]()
    var delegate: PlaylistCellDelegate?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch musicState {
        case .spotify:
            return spotifyPlaylists.count
        case .local:
            return localPlaylists.count
        case .none:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(String(PlaylistCell), forIndexPath: indexPath) as? PlaylistCell else { fatalError() }
        
        cell.musicState = musicState
        cell.backgroundColor = UIColor(white: 0, alpha: 0)
        cell.playButton.tintColor = UIColor.darkGrayColor()
        switch musicState {
        case .spotify:
            guard spotifyPlaylists.count > 0 else { break }
            let playlist = spotifyPlaylists[indexPath.row]
            var image: UIImage?
            if images.count > 0 {
                image = images[indexPath.row]
            }
            cell.configureWithSpotify(playlist, image: image)
        case .local:
            if let playlist = localPlaylists[indexPath.row] as? MPMediaPlaylist {
                cell.configureWithLocal(playlist)
            }
        case .none:
            return cell
        }
        cell.delegate = delegate
        return cell
    }
}
