//
//  ViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import Reactor
import AVFoundation
import MediaPlayer
import Hero

class MainViewController: UIViewController {

    // MARK: - Properties
    
    let spotifyService = SpotifyService()
    var musicState = MusicState.none
    var core = App.sharedCore
    var session: SPTSession?
    
    var selectedPlaylist: MPMediaItemCollection?
    var trackPercent: Double = 0.0
    var playback = Playback.stopped
    
    var audioRecorder: AVAudioRecorder?
    var audioSession: AVAudioSession?
    var timer: Timer?
    var player = SPTAudioStreamingController.sharedInstance()
    
    
    var blurView: UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        return UIVisualEffectView(effect: blurEffect)
    }
    
    
    // MARK: - Interface properties
    
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var spotifyLogo: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var spotifyLoginButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var playlistsDataSource: PlaylistsDataSource!
    @IBOutlet weak var playLocalButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        playlistsDataSource.delegate = self
        tableView.tableFooterView = UIView()
        visualEffectView.effect = nil
        
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        core.add(subscriber: self)
        spotifyLoginButton.layer.cornerRadius = 5
        spotifyLoginButton.clipsToBounds = true
        playLocalButton.layer.cornerRadius = 5
        playLocalButton.clipsToBounds = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        core.remove(subscriber: self)
    }
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) { }
    
    
    // MARK: - Interface actions
    
    @IBAction func spotifyLoginTapped(_ sender: AnyObject) {
        core.fire(event: Selected(item: MusicState.spotify))
    }
    
    @IBAction func playLocalButtonTapped() {
        core.fire(event: Selected(item: MusicState.local))
        core.fire(event: Updated(item: ViewState.viewing))
    }

    @IBAction func switchMusicStateTapped(_ sender: AnyObject) {
        core.fire(event: RecordingStopped())
        core.fire(event: Updated(item: MusicState.none))
        core.fire(event: Updated(item: ViewState.preLoggedIn))
    }
    
    
    // MARK: - Background blur
    
    func blurBackground() {
        DispatchQueue.main.async {
            if self.visualEffectView.effect == nil {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.spotifyLoginButton.alpha = 0.0
                    self.playLocalButton.alpha = 0.0
                    self.spotifyLogo.alpha = 0.0
                }, completion: { (done) in
                    UIView.animate(withDuration: 0.5, animations: { 
                        self.visualEffectView.effect = UIBlurEffect(style: .light)
                        self.tableView.alpha = 1.0
                        self.navigationController?.isNavigationBarHidden = false
                    })
                })
            }
        }

        switch musicState {
        case .spotify:
            title = "Spotify Playlists"
        case .local:
            title = "Local Playlists"
        default:
            title = ""
        }
    }
    
    func removeBlurFromBackground() {
        DispatchQueue.main.async {
            if self.visualEffectView.effect != nil {
                UIView.animate(withDuration: 0.5, animations: {
                    self.navigationController?.isNavigationBarHidden = true
                    self.visualEffectView.effect = nil
                    self.tableView.alpha = 0.0
                }, completion: { (done) in
                    UIView.animate(withDuration: 0.5, animations: { 
                        self.spotifyLoginButton.alpha = 1.0
                        self.playLocalButton.alpha = 1.0
                        self.spotifyLogo.alpha = 1.0
                    })
                    
                })
            }
        }

    }
}


// MARK: - Table view delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPlaylistDetails", sender: self)
        switch musicState {
        case .spotify:
            let playlist: SPTPartialPlaylist = playlistsDataSource.spotifyPlaylists[indexPath.row]
            core.fire(event: Selected(item: playlist))
            core.fire(command: GetSpotifyPlaylistDetails())
        case .local:
            guard let playlist = playlistsDataSource.localPlaylists[indexPath.row] as? MPMediaPlaylist else { break }
            core.fire(event: Selected(item: playlist))
        case .none:
            break
        }
            }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
}


// MARK: - Playlist cell delegate

extension MainViewController: PlaylistCellDelegate {
    
    func playSpotify(_ playlist: SPTPartialPlaylist) {
        core.fire(command: PlaySpotifyPlaylist(playlist: playlist))
    }
    
    func playLocal(_ playlist: MPMediaPlaylist) {
        core.fire(event: Selected(item: playlist))
        core.fire(command: PlayLocalSelectedPlaylist())
    }
    
}



// MARK: - Playback view delegate



// MARK: - subscriber

extension MainViewController: Subscriber {
    
    func update(with state: AppState) {
        musicState = state.musicState
        playlistsDataSource.musicState = state.musicState
        
        switch musicState {
        case .spotify:
            self.session = state.spotifyState.session
            switch state.viewState {
            case .preLoggedIn:
                if state.spotifyState.session == nil {
                    core.fire(command: LoginToSpotify())
                } else {
                    core.fire(event: Updated(item: ViewState.viewing))
                    blurBackground()
                }
            case let .loading(message):
                showLoadingBanner(message)
                blurBackground()
            case .viewing:
                dismissBanner()
                let dataSourceLoaded = playlistsDataSource.spotifyPlaylists.count != 0
                playlistsDataSource.spotifyPlaylists = state.spotifyState.playlists
                if playlistsDataSource.currentSpotifyPlaylist != state.spotifyState.currentPlaylist {
                    playlistsDataSource.currentSpotifyPlaylist = state.spotifyState.currentPlaylist
                    tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                } else if !dataSourceLoaded {
                    tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                }
                
                if playlistsDataSource.spotifyPlaylists.count == 0 {
                    tableView.backgroundView = emptyStateView
                }
                
            case let .error(message):
                showErrorBanner(message)
            }
        case .local:
            blurBackground()
            if MPMediaLibrary.authorizationStatus() == .authorized && !state.localMusicState.playlistsLoaded {
                core.fire(command: GetLocalPlaylists())
                core.fire(command: RequestPermissionToRecord())
            } else if MPMediaLibrary.authorizationStatus() != .authorized {
                MPMediaLibrary.requestAuthorization({ (status) in
                    self.core.fire(command: GetLocalPlaylists())
                    self.core.fire(command: RequestPermissionToRecord())
                })
            } else {
                playlistsDataSource.localPlaylists = state.localMusicState.playlists
                playlistsDataSource.currentLocalPlaylist = state.localMusicState.selectedPlaylist
                if playlistsDataSource.localPlaylists.count == 0 {
                    tableView.backgroundView = emptyStateView
                }
                tableView.reloadData()

                trackPercent = state.localMusicState.trackPercent
                playback = state.localMusicState.playback
            }
        case .none:
            removeBlurFromBackground()
            playlistsDataSource.localPlaylists = []
            playlistsDataSource.spotifyPlaylists = []
            tableView.reloadData()
        }
    }
    
}


