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
        case let action as SessionLoaded:
            state.session = action.session
        default:
            break
        }
        
        return state
    }
    
}


