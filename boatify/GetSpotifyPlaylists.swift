//
//  GetSpotifyPlaylists.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct GetSpotifyPlaylists: Command {
    
    func execute(state: AppState, core: Core<AppState>) {
        SPTPlaylistList.playlists(forUser: state.spotifyState.session?.canonicalUsername, withAccessToken: state.spotifyState.session?.accessToken, callback: { (error, list) in
            
            guard let playlists = list as? SPTPlaylistList else { return }
            guard let partialPlaylists = playlists.tracksForPlayback() as? [SPTPartialPlaylist] else { return }
            let imageURIs = partialPlaylists.map { $0.largestImage.imageURL }
            var images = [UIImage]()
            
            for uri in imageURIs {
                if let uri = uri, let imageData = try? Data(contentsOf: uri), let image = UIImage(data: imageData) {
                    images.append(image)
                }
            }
            core.fire(event: Loaded(items: partialPlaylists))
            core.fire(event: Loaded(items: images))
        })
    }
    
}
