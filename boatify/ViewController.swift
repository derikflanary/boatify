//
//  ViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit
import ReSwift

class ViewController: UIViewController {

    // MARK: -  Properties
    
    let spotifyService = SpotifyService()
    var store = AppState.sharedStore
    var session: SPTSession?
    var player = SPTAudioStreamingController.sharedInstance()
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
    
    
    // MARK: - View cycle overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }

    func updateAfterLogin() {
        guard let session = session else { return }
        
        spotifyLoginButton.hidden = true
        do {
            try player.startWithClientId(SpotifyService.kClientId)
            player.loginWithAccessToken(session.accessToken)
        } catch {
            print(error)
        }
        print("login success")
    }

    
    // MARK: - Interface actions
    
    @IBAction func spotifyLoginTapped(sender: AnyObject) {
        spotifyService.loginToSpotify()
    }

}


// MARK: Streaming delegate

extension ViewController: SPTAudioStreamingDelegate {

    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        guard let url = NSURL(string: "spotify:track:58s6EuEYJdlb0kO7awm3Vp") else { return }
        
        player.playURIs([url], withOptions: SPTPlayOptions()) { error in
            if error != nil {
                print(error)
            }
        }
    }
    
}


// MARK: - Store subscriber

extension ViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        guard let session = state.session else { return }
        self.session = session
        updateAfterLogin()
    }
}


