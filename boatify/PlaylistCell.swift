//
//  PlaylistCell.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit

protocol PlaylistCellDelegate {
    func play(uri: NSURL)
}

class PlaylistCell: UITableViewCell {
    
    var delegate: PlaylistCellDelegate?
    var playlist: SPTPartialPlaylist?
    
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playlistDetailLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonTapped() {
        guard let playlist = playlist where playlist.playableUri != nil else { return }
        delegate?.play(playlist.playableUri)
        print("play pressed")
    }
    
    func configure(playlist: SPTPartialPlaylist, image: UIImage) {
        self.playlist = playlist
        playlistImageView.image = image
        nameLabel.text = playlist.name
        playlistDetailLabel.text = "\(playlist.trackCount) songs"
        layoutIfNeeded()
    }
}
