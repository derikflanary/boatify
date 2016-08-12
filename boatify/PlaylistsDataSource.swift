//
//  PlaylistsDataSource.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit

class PlaylistsDataSource: NSObject, UITableViewDataSource {

    var playlists = [SPTPartialPlaylist]()
    var images = [UIImage]()
    var delegate: PlaylistCellDelegate?
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(String(PlaylistCell), forIndexPath: indexPath) as? PlaylistCell else { fatalError() }
        
        let playlist = playlists[indexPath.row]
        let image = images[indexPath.row]
        cell.configure(playlist, image: image)
        cell.delegate = delegate
        return cell
    }
}
