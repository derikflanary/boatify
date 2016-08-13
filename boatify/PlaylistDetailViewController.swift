//
//  PlaylistDetailViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import ReSwift


class PlaylistDetailViewController: UIViewController {
    
    var store = AppState.sharedStore
    var trackURIs = [NSURL]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tracksDataSource: TracksDataSource!
    
    // MARK: - View life cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
}


// MARK: - Tableview delgate

extension PlaylistDetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = tracksDataSource.tracks[indexPath.row]
        let options = SPTPlayOptions()
        options.trackIndex = Int32(indexPath.row)
        SPTAudioStreamingController.sharedInstance().playURIs(trackURIs, withOptions: options, callback: nil)
    }
}


// MARK: - Store subscriber

extension PlaylistDetailViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        
        trackURIs = state.tracks.map { $0.playableUri }
        tracksDataSource.tracks = state.tracks
        tableView.reloadData()
    }
    
}
