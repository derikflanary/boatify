//
//  HandleAuth.swift
//  boatify
//
//  Created by Derik Flanary on 3/7/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import Reactor

struct HandleAuth: Command {
    
    let url: URL
    var core = App.sharedCore
    
    init(url: URL){
        self.url = url
    }
    
    func execute(state: AppState, core: Core<AppState>) {
        SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url, callback: { error, session in
            if let error = error {
                print(error)
            } else {
                guard let session = session else { return }
                core.fire(event: Retrieved(item: session))
                core.fire(command: LoginPlayer(session: session))
            }
        })
    }
    
}

