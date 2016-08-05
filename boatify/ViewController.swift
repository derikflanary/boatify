//
//  ViewController.swift
//  boatify
//
//  Created by Derik Flanary on 8/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let kClientId = "08e656aa8c444173ab066eb4a3ca7bf7"
    let kCallbackURL = "boatify-login://callback"
    var session: SPTSession?
    var player = SPTAudioStreamingController.sharedInstance()
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateAfterLogin), name: "loginSuccessful", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    func updateAfterLogin() {
        guard let sessionData = NSUserDefaults.standardUserDefaults().objectForKey("SpotifySession") as? NSData, sesh = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession else { return }
        session = sesh
        spotifyLoginButton.hidden = true
        do {
            try player.startWithClientId(kClientId)
            player.loginWithAccessToken(sesh.accessToken)
        } catch {
            print(error)
        }
        print("login success")
    }

    @IBAction func spotifyLoginTapped(sender: AnyObject) {
        SPTAuth.defaultInstance().clientID = kClientId
        SPTAuth.defaultInstance().redirectURL = NSURL(string: kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        let loginURL = SPTAuth.defaultInstance().loginURL
        UIApplication.sharedApplication().openURL(loginURL)
    }
    

}


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


