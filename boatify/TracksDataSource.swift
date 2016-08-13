//
//  TracksDataSource.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit

class TracksDataSource: NSObject, UITableViewDataSource {
    
    var tracks = [SPTPartialTrack]()
    var selectedTrack: SPTPartialTrack?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(String(TrackCell), forIndexPath: indexPath) as? TrackCell else { fatalError() }
        
        let track = tracks[indexPath.row]
        cell.configure(track, selectedTrack: selectedTrack)
        return cell
    }
    
}
