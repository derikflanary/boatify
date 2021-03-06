//
//  PlaylistCell.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import MediaPlayer
import Kingfisher

protocol PlaylistCellDelegate {
    func playSpotify(_ playlist: SPTPartialPlaylist)
    func playLocal(_ playlist: MPMediaPlaylist)
}

class PlaylistCell: UITableViewCell, ReusableView {
    
    var delegate: PlaylistCellDelegate?
    var spotifyPlaylist: SPTPartialPlaylist?
    var localPlaylist: MPMediaPlaylist?
    var musicState = MusicState.none
    
    
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playlistDetailLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonTapped() {
        switch musicState {
        case .spotify:
            guard let playlist = spotifyPlaylist, playlist.playableUri != nil else { return }
            delegate?.playSpotify(playlist)
        case .local:
            guard let playlist = localPlaylist else { return }
            delegate?.playLocal(playlist)
        case .none:
            break
        }
        
    }
    
    func configureWithSpotify(_ playlist: SPTPartialPlaylist, currentPlaylist: SPTPartialPlaylist?) {
        self.spotifyPlaylist = playlist
        playlistImage.kf.setImage(with: playlist.smallestImage.imageURL)
        nameLabel.text = playlist.name
        playlistDetailLabel.text = "\(playlist.trackCount) songs"
        if playlist == currentPlaylist {
            backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        } else {
            backgroundColor = UIColor.clear
        }
        layoutIfNeeded()
    }
    
    func configureWithLocal(_ playlist: MPMediaPlaylist, currentPlaylist: MPMediaPlaylist?) {
        localPlaylist = playlist
        nameLabel.text = playlist.name
        playlistDetailLabel.text = "\(playlist.count) songs"
        if playlist == currentPlaylist {
            backgroundColor = UIColor(white: 1.0, alpha: 0.4)
        } else {
            backgroundColor = UIColor.clear
        }
        layoutIfNeeded()
    }
}
