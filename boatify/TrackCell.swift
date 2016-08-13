//
//  TrackCell.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    
    func configure(track: SPTPartialTrack, selectedTrack: SPTPartialTrack?) {
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
}
