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
    func playSpotify(uri: NSURL)
    func playLocal(url: NSURL)
}

class PlaylistCell: UITableViewCell {
    
    var delegate: PlaylistCellDelegate?
    var spotifyPlaylist: SPTPartialPlaylist?
    var localPlaylist: MPMediaItemCollection?
    var musicState = MusicState.none
    
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playlistDetailLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonTapped() {
        switch musicState {
        case .spotify:
            guard let playlist = spotifyPlaylist where playlist.playableUri != nil else { return }
            delegate?.playSpotify(playlist.playableUri)
        case .local:
            break
        case .none:
            break
        }
        
    }
    
    func configureWithSpotify(playlist: SPTPartialPlaylist, image: UIImage) {
        self.spotifyPlaylist = playlist
        playlistImageView.image = image
        nameLabel.text = playlist.name
        playlistDetailLabel.text = "\(playlist.trackCount) songs"
        layoutIfNeeded()
    }
    
    func configureWithLocal(playlist: MPMediaItemCollection) {
        localPlaylist = playlist
        playlistDetailLabel.text = "\(playlist.count) songs"
        guard let item = playlist.representativeItem else { return }
        nameLabel.text = item.title
        layoutIfNeeded()
    }
}
