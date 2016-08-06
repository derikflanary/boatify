//
//  AppReducer.swift
//  boatify
//
//  Created by Derik Flanary on 8/6/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

//
//  AppReducer.swift
//  greatwork
//
//  Created by Tim on 4/7/16.
//  Copyright © 2016 OC Tanner Company, Inc. All rights reserved.
//

import Foundation
import ReSwift
import UIKit


struct AppReducer: Reducer {
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        var state = state ?? AppState()
        
        switch action {
        case _ as AppLaunched:
            guard let sessionData = NSUserDefaults.standardUserDefaults().objectForKey("SpotifySession") as? NSData, session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as? SPTSession else { break }
            state.session = session
        case let action as SessionLoaded:
            state.session = action.session
            let sessionData = NSKeyedArchiver.archivedDataWithRootObject(action.session)
            NSUserDefaults.standardUserDefaults().setObject(sessionData, forKey:"SpotifySession")
        default:
            break
        }
        
        return state
    }
    
}


