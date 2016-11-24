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
    
    func showTemporaryMessage(_ title: String) {
        let murmur = Murmur(title: title, backgroundColor: UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0), titleColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 14.0))
        Whisper.show(whistle: murmur, action: .show(2.0))
    }
    
    func showErrorBanner(_ error: String) {
        let murmur = Murmur(title: error, backgroundColor: UIColor.red, titleColor: UIColor.white, font: UIFont.systemFont(ofSize: 14.0))
        Whisper.show(whistle: murmur, action: .show(3.0))
    }
    
    func showLoadingBanner(_ title: String) {
        guard let navigationController = navigationController else { return }
        
        for subview in navigationController.navigationBar.subviews {
            if subview is WhisperView {
                return
            }
        }
        let message = Message(title: title, textColor: UIColor.darkGray, backgroundColor: UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0), images: nil)
        Whisper.show(whisper: message, to: navigationController)
    }
    
    func dismissBanner() {
        guard let navigationController = navigationController else { return }
        hide(whisperFrom: navigationController)
    }
    
}
