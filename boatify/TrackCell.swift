//
//  TrackCell.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import MediaPlayer

class TrackCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    
    func configureSpotify(track: SPTPartialTrack, selectedTrack: SPTPartialTrack?) {
        nameLabel.text = track.name
        if let artists = track.artists as? [SPTPartialArtist] {
            let artist = artists.first
            artistLabel.text = artist?.name
        }
        if track == selectedTrack {
            nameLabel.textColor = UIColor.blueColor()
        } else {
            nameLabel.textColor = UIColor.darkGrayColor()
        }
    }
    
    func configureLocal(track: MPMediaItem, selectedTrack: MPMediaItem?) {
        nameLabel.text = track.title
        artistLabel.text = track.artist
        if track == selectedTrack {
            nameLabel.textColor = UIColor.blueColor()
        } else {
            nameLabel.textColor = UIColor.darkGrayColor()
        }
    }
}
