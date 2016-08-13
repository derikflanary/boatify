//
//  ViewController+Extensions.swift
//  boatify
//
//  Created by Derik Flanary on 8/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit
import Whisper

extension UIViewController {
    
    func showTemporaryMessage(title: String) {
        let murmur = Murmur(title: title, backgroundColor: UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0), titleColor: UIColor.darkGrayColor(), font: UIFont.systemFontOfSize(14.0))
        show(whistle: murmur, action: .Show(2.0))
    }
    
    func showErrorBanner(error: String) {
        let murmur = Murmur(title: error, backgroundColor: UIColor.redColor(), titleColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14.0))
        show(whistle: murmur, action: .Show(3.0))
    }
    
    func showLoadingBanner(title: String) {
        guard let navigationController = navigationController else { return }
        
        for subview in navigationController.navigationBar.subviews {
            if subview is WhisperView {
                return
            }
        }
        let message = Message(title: title, textColor: UIColor.darkGrayColor(), backgroundColor: UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0), images: nil)
        show(whisper: message, to: navigationController)
    }
    
    func dismissBanner() {
        guard let navigationController = navigationController else { return }
        hide(whisperFrom: navigationController)
    }
    
}