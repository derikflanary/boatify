//
//  PlaylistCell.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import MediaPlayer

protocol PlaylistCellDelegate {
    func playSpotify(_ uri: URL)
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
            delegate?.playSpotify(playlist.playableUri)
        case .local:
            guard let playlist = localPlaylist else { return }
            delegate?.playLocal(playlist)
        case .none:
            break
        }
        
    }
    
    func configureWithSpotify(_ playlist: SPTPartialPlaylist, image: UIImage?) {
        self.spotifyPlaylist = playlist
        playlistImage.image = image
        nameLabel.text = playlist.name
        playlistDetailLabel.text = "\(playlist.trackCount) songs"
        layoutIfNeeded()
    }
    
    func configureWithLocal(_ playlist: MPMediaPlaylist) {
        localPlaylist = playlist
        nameLabel.text = playlist.name
        playlistDetailLabel.text = "\(playlist.count) songs"
        layoutIfNeeded()
    }
}
